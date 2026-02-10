/** @type {import("/Users/jacob/.cache/opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts").Plugin} */
export const NotificationPlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  let lastMessageTime;
  let activeRootSessionID;
  let lastPostedStatus;
  let lastPermissionSessionID;
  let lastPermissionNotificationAt = 0;
  const primarySessionCache = new Map();
  const WAITING_NOTIFICATION_DEBOUNCE_MS = 1500;
  const OPENCODE_STATUS = {
    complete: "complete",
    inProgress: "in_progress",
    waiting: "waiting",
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
    if (!status || status === lastPostedStatus) {
      return;
    }

    lastPostedStatus = status;
    postWeztermStatus(status);
  };

  const fetchIsPrimarySession = async (sessionID) => {
    if (!sessionID) {
      return false;
    }

    if (primarySessionCache.has(sessionID)) {
      return primarySessionCache.get(sessionID);
    }

    try {
      const session = await client.session.get({
        path: { id: sessionID },
      });

      const isPrimary = !session.data?.parentID;
      primarySessionCache.set(sessionID, isPrimary);
      if (session.data?.id) {
        primarySessionCache.set(session.data.id, isPrimary);
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

    if (activeRootSessionID) {
      return sessionID === activeRootSessionID;
    }

    const isPrimary = await fetchIsPrimarySession(sessionID);
    if (isPrimary) {
      activeRootSessionID = sessionID;
    }
    return isPrimary;
  };

  const shouldSendWaitingNotification = (sessionID) => {
    const now = Date.now();
    if (
      sessionID &&
      sessionID === lastPermissionSessionID &&
      now - lastPermissionNotificationAt < WAITING_NOTIFICATION_DEBOUNCE_MS
    ) {
      return false;
    }

    lastPermissionSessionID = sessionID;
    lastPermissionNotificationAt = now;
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
    return event?.properties?.sessionID;
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

        const elapsedMs = lastMessageTime ? new Date() - lastMessageTime : 0;
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

      // Send notification when opencode asks for permission (via event)
      if (event.type === "permission.asked" || event.type === "permission.updated") {
        const permissionSessionID = eventSessionID ?? activeRootSessionID;
        if (!(await shouldTrackSession(permissionSessionID))) {
          return;
        }

        await notifyWaitingForInput(permissionSessionID);
      }

      if (event.type === "permission.replied") {
        const permissionSessionID = eventSessionID ?? activeRootSessionID;
        if (!(await shouldTrackSession(permissionSessionID))) {
          return;
        }

        setWeztermStatus(OPENCODE_STATUS.inProgress);
      }
    },
    "chat.message": async (input) => {
      const sessionID =
        input?.sessionID ??
        input?.message?.sessionID ??
        input?.output?.message?.sessionID;

      if (!sessionID) {
        return;
      }

      if (!(await fetchIsPrimarySession(sessionID))) {
        return;
      }

      activeRootSessionID = sessionID;

      // Set last message time
      lastMessageTime = new Date();
      setWeztermStatus(OPENCODE_STATUS.inProgress);
    },
    "permission.updated": async (input) => {
      const sessionID =
        input?.event?.properties?.sessionID ??
        input?.event?.sessionID ??
        input?.permission?.sessionID ??
        input?.sessionID ??
        activeRootSessionID;

      if (!(await shouldTrackSession(sessionID))) {
        return;
      }

      await notifyWaitingForInput(sessionID);
    },
  };
};
