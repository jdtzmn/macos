import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function browserCommand(url: string): [string, string[]] {
  switch (process.platform) {
    case "darwin":
      return ["open", [url]];
    case "win32":
      return ["cmd", ["/c", "start", "", url]];
    default:
      return ["xdg-open", [url]];
  }
}

function errorMessage(stderr: string, fallback: string): string {
  return stderr.trim() || fallback;
}

export default function openPrExtension(pi: ExtensionAPI) {
  pi.registerCommand("open", {
    description: "Open the current PR (or /open <number>, new, repo) in a browser",
    handler: async (args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("/open is available only in interactive Pi.", "error");
        return;
      }

      const arg = args.trim();
      const fail = (message: string) => ctx.ui.notify(message, "error");

      try {
        let url: string;
        let label: string;

        if (arg === "repo") {
          const repo = await pi.exec("gh", ["repo", "view", "--json", "url", "--jq", ".url"]);
          if (repo.code !== 0) return fail(errorMessage(repo.stderr, "Not a GitHub repository."));
          url = repo.stdout.trim();
          label = "repository";
        } else if (arg === "new") {
          const [repo, branch] = await Promise.all([
            pi.exec("gh", ["repo", "view", "--json", "url", "--jq", ".url"]),
            pi.exec("git", ["rev-parse", "--abbrev-ref", "HEAD"]),
          ]);
          if (repo.code !== 0) return fail(errorMessage(repo.stderr, "Not a GitHub repository."));
          if (branch.code !== 0) return fail("Could not determine the current branch.");

          const head = branch.stdout.trim();
          url = `${repo.stdout.trim()}/compare/${encodeURIComponent(head)}?expand=1`;
          label = `new pull request from ${head}`;
        } else {
          const pr = await pi.exec("gh", [
            "pr",
            "view",
            ...(arg ? [arg] : []),
            "--json",
            "number,title,url,state",
          ]);
          if (pr.code !== 0) {
            if (/no pull requests? found/i.test(pr.stderr)) {
              return fail("No PR for this branch yet. Try `/open new` to start one.");
            }
            return fail(errorMessage(pr.stderr, "Could not find that pull request."));
          }

          const data = JSON.parse(pr.stdout) as {
            number: number;
            title: string;
            url: string;
            state: string;
          };
          url = data.url;
          label = `#${data.number} ${data.title} (${data.state.toLowerCase()})`;
        }

        if (!url) return fail("GitHub did not return a URL to open.");

        const [command, commandArgs] = browserCommand(url);
        const opened = await pi.exec(command, commandArgs);
        if (opened.code !== 0) {
          return ctx.ui.notify(`Could not launch a browser. URL: ${url}`, "warning");
        }

        ctx.ui.notify(`Opened ${label}\n${url}`, "info");
      } catch (error: unknown) {
        fail(`Error: ${error instanceof Error ? error.message : String(error)}`);
      }
    },
  });
}
