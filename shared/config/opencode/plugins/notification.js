/** @type {import("/Users/jacob/.cache/opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts").Plugin} */
export const NotificationPlugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  let lastMessageTime;

  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        // Fetch session info to check if it's a subagent
        const session = await client.session.get({
          path: { id: event.properties.sessionID },
        });

        // Only notify for main sessions (no parentID)
        if (session.data?.parentID) {
          return;
        }

        const numberOfSeconds = Math.floor(
          (new Date() - lastMessageTime) / 1000,
        );
        await $`sh -c "terminal-notifier -title 'Opencode' -message 'Completed in ${numberOfSeconds}s' -sound 'Purr' -group 'opencode' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }

      // Send notification on session error
      if (event.type === "session.error") {
        const errorName = event.properties.error?.name ?? "Unknown error";
        const errorMessage =
          event.properties.error?.message ?? "No error message";
        await $`sh -c "terminal-notifier -title 'Opencode Error' -subtitle '${errorName}' -message '${errorMessage}' -sound 'Basso' -group 'opencode-error' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
      }
    },
    "chat.message": async ({ message }) => {
      // Set last message time
      lastMessageTime = new Date();
    },
    "permission.updated": async ({ event }) => {
      // Send notification when opencode asks for user input
      await $`sh -c "terminal-notifier -title 'Opencode' -message 'Waiting for user input...' -sound 'Pop' -group 'opencode-input' -activate 'dev.zed.Zed' > /dev/null 2>&1"`;
    },
  };
};
