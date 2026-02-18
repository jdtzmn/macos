/** @type {import("/Users/jacob/.cache/opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts").Plugin} */
export const NotificationPlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const OPENCODE_STATUS = {
    complete: "complete",
    inProgress: "in_progress",
    waiting: "waiting",
  };
  const WAITING_NOTIFICATION_DEBOUNCE_MS = 1500;
  const state = {
    lastMessageTime: undefined,
    activeRootSessionID: undefined,
    lastPostedStatus: undefined,
    lastInputSessionID: undefined,
    lastInputNotificationAt: 0,
    primarySessionCache: new Map(),
  };

  const resolveSessionID = (...values) => {
    return values.find((value) => typeof value === "string" && value.length > 0);
  };

  const postWeztermStatus = (status) => {
    if (!status || !process.stdout || typeof process.stdout.write !== "function") {
      return;
    }

    const encodedValue = Buffer.from(status).toString("base64");
    if (process.env.TMUX) {
      process.stdout.write(
        `\u001bPtmux;\u001b\u001b]1337;SetUserVar=opencode_status=${encodedValue}\u0007\u001b\\`,
      );
      return;
    }

    process.stdout.write(
      `\u001b]1337;SetUserVar=opencode_status=${encodedValue}\u0007`,
    );
  };

  const setWeztermStatus = (status) => {
    if (!status || status === state.lastPostedStatus) {
      return;
    }

    state.lastPostedStatus = status;
    postWeztermStatus(status);
  };

  const fetchIsPrimarySession = async (sessionID) => {
    if (!sessionID) {
      return false;
    }

    if (state.primarySessionCache.has(sessionID)) {
      return state.primarySessionCache.get(sessionID);
    }

    try {
      const session = await client.session.get({
        path: { id: sessionID },
      });

      const isPrimary = !session.data?.parentID;
      state.primarySessionCache.set(sessionID, isPrimary);
      if (session.data?.id) {
        state.primarySessionCache.set(session.data.id, isPrimary);
      }
      return isPrimary;
    } catch {
      return false;
    }
  };

  const shouldTrackSession = async (sessionID) => {
    if (!sessionID) {
      return false;
    }

    if (state.activeRootSessionID) {
      return sessionID === state.activeRootSessionID;
    }

    const isPrimary = await fetchIsPrimarySession(sessionID);
    if (isPrimary) {
      state.activeRootSessionID = sessionID;
    }
    return isPrimary;
  };

  const shouldTrackInputSession = async (sessionID) => {
    if (await shouldTrackSession(sessionID)) {
      return true;
    }

    if (!sessionID || !state.activeRootSessionID) {
      return false;
    }

    try {
      const session = await client.session.get({
        path: { id: sessionID },
      });
      return session.data?.parentID === state.activeRootSessionID;
    } catch {
      return false;
    }
  };

  const shouldSendWaitingNotification = (sessionID) => {
    const now = Date.now();
    if (
      sessionID &&
      sessionID === state.lastInputSessionID &&
      now - state.lastInputNotificationAt < WAITING_NOTIFICATION_DEBOUNCE_MS
    ) {
      return false;
    }

    state.lastInputSessionID = sessionID;
    state.lastInputNotificationAt = now;
    return true;
  };

  const notifyWaitingForInput = async (sessionID) => {
    setWeztermStatus(OPENCODE_STATUS.waiting);
    if (!shouldSendWaitingNotification(sessionID)) {
      return;
    }

    await $`sh -c "terminal-notifier -title 'Opencode' -message 'Waiting for user input...' -sound 'Pop' -group 'opencode-input' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
  };

  const getEventSessionID = (event) => {
    return resolveSessionID(event?.properties?.sessionID);
  };

  const getChatMessageSessionID = (input) => {
    return resolveSessionID(
      input?.sessionID,
      input?.message?.sessionID,
      input?.output?.message?.sessionID,
    );
  };

  const getInputHookSessionID = (input) => {
    return resolveSessionID(
      input?.event?.properties?.sessionID,
      input?.event?.sessionID,
      input?.permission?.sessionID,
      input?.sessionID,
      state.activeRootSessionID,
    );
  };

  const getInputEventSessionID = (eventSessionID) => {
    return resolveSessionID(eventSessionID, state.activeRootSessionID);
  };

  return {
    event: async ({ event }) => {
      const eventSessionID = getEventSessionID(event);

      if (event.type === "session.status") {
        if (!(await shouldTrackSession(eventSessionID))) {
          return;
        }

        const statusType = event.properties.status?.type;
        if (statusType === "busy" || statusType === "retry") {
          setWeztermStatus(OPENCODE_STATUS.inProgress);
        }
        if (statusType === "idle") {
          setWeztermStatus(OPENCODE_STATUS.complete);
        }
      }

      // Send notification on session completion
      if (event.type === "session.idle") {
        if (!(await shouldTrackSession(eventSessionID))) {
          return;
        }

        setWeztermStatus(OPENCODE_STATUS.complete);

        const elapsedMs = state.lastMessageTime ? new Date() - state.lastMessageTime : 0;
        const numberOfSeconds = Math.max(0, Math.floor(elapsedMs / 1000));
        await $`sh -c "terminal-notifier -title 'Opencode' -message 'Completed in ${numberOfSeconds}s' -sound 'Purr' -group 'opencode' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }

      // Send notification on session error
      if (event.type === "session.error") {
        if (!(await shouldTrackSession(eventSessionID))) {
          return;
        }

        setWeztermStatus(OPENCODE_STATUS.waiting);

        const errorName = event.properties.error?.name ?? "Unknown error";
        const errorMessage =
          event.properties.error?.message ?? "No error message";
        await $`sh -c "terminal-notifier -title 'Opencode Error' -subtitle '${errorName}' -message '${errorMessage}' -sound 'Basso' -group 'opencode-error' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }

      // Send notification when opencode is waiting for user input (permission or question)
      // Use shouldTrackInputSession to also handle subagent requests.
      const inputAskedEvents = ["permission.asked", "permission.updated", "question.asked"];
      const inputResolvedEvents = ["permission.replied", "question.replied", "question.rejected"];

      if (inputAskedEvents.includes(event.type)) {
        const inputSessionID = getInputEventSessionID(eventSessionID);
        if (!(await shouldTrackInputSession(inputSessionID))) {
          return;
        }

        await notifyWaitingForInput(inputSessionID);
      }

      if (inputResolvedEvents.includes(event.type)) {
        const inputSessionID = getInputEventSessionID(eventSessionID);
        if (!(await shouldTrackInputSession(inputSessionID))) {
          return;
        }

        setWeztermStatus(OPENCODE_STATUS.inProgress);
      }
    },
    "chat.message": async (input) => {
      const sessionID = getChatMessageSessionID(input);

      if (!sessionID) {
        return;
      }

      if (!(await fetchIsPrimarySession(sessionID))) {
        return;
      }

      state.activeRootSessionID = sessionID;

      // Set last message time
      state.lastMessageTime = new Date();
      setWeztermStatus(OPENCODE_STATUS.inProgress);
    },
    "permission.updated": async (input) => {
      const sessionID = getInputHookSessionID(input);

      if (!(await shouldTrackInputSession(sessionID))) {
        return;
      }

      await notifyWaitingForInput(sessionID);
    },
  };
};
