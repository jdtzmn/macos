/** @type {import("/Users/jacob/.cache/opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts").Plugin} */
export const NotificationPlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  let lastMessageTime;
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

  return {
    event: async ({ event }) => {
      if (event.type === "session.status") {
        const statusType = event.properties.status?.type;
        if (statusType === "busy" || statusType === "retry") {
          postWeztermStatus(OPENCODE_STATUS.inProgress);
        }
        if (statusType === "idle") {
          postWeztermStatus(OPENCODE_STATUS.complete);
        }
      }

      // Send notification on session completion
      if (event.type === "session.idle") {
        postWeztermStatus(OPENCODE_STATUS.complete);

        // Fetch session info to check if it's a subagent
        const session = await client.session.get({
          path: { id: event.properties.sessionID },
        });

        // Only notify for main sessions (no parentID)
        if (session.data?.parentID) {
          return;
        }

        const elapsedMs = lastMessageTime ? new Date() - lastMessageTime : 0;
        const numberOfSeconds = Math.max(0, Math.floor(elapsedMs / 1000));
        await $`sh -c "terminal-notifier -title 'Opencode' -message 'Completed in ${numberOfSeconds}s' -sound 'Purr' -group 'opencode' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }

      // Send notification on session error
      if (event.type === "session.error") {
        postWeztermStatus(OPENCODE_STATUS.waiting);

        const errorName = event.properties.error?.name ?? "Unknown error";
        const errorMessage =
          event.properties.error?.message ?? "No error message";
        await $`sh -c "terminal-notifier -title 'Opencode Error' -subtitle '${errorName}' -message '${errorMessage}' -sound 'Basso' -group 'opencode-error' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }

      // Send notification when opencode asks for permission (via event)
      if (event.type === "permission.asked") {
        postWeztermStatus(OPENCODE_STATUS.waiting);

        await $`sh -c "terminal-notifier -title 'Opencode' -message 'Waiting for user input...' -sound 'Pop' -group 'opencode-input' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }

      if (event.type === "permission.replied") {
        postWeztermStatus(OPENCODE_STATUS.inProgress);
      }
    },
    "chat.message": async ({ message }) => {
      // Set last message time
      lastMessageTime = new Date();
      postWeztermStatus(OPENCODE_STATUS.inProgress);
    },
    "permission.updated": async ({ event }) => {
      postWeztermStatus(OPENCODE_STATUS.waiting);

      // Send notification when opencode asks for user input
      await $`sh -c "terminal-notifier -title 'Opencode' -message 'Waiting for user input...' -sound 'Pop' -group 'opencode-input' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
    },
  };
};
