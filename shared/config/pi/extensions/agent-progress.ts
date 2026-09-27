// Installed by herdr-agent-progress; load beside Herdr's official Pi integration.
import { execFile } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const exec = promisify(execFile);
const configHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config");
const launcher = path.join(configHome, "herdr", "plugins", "config", "agent-progress", "herdr-progress");

export default function (pi: ExtensionAPI) {
  if (process.env.HERDR_ENV !== "1" || !process.env.HERDR_PANE_ID) return;

  let lastCheck = 0;
  let reportedFailure = false;

  async function check(ctx: ExtensionContext, event: "prompt" | "tool"): Promise<string | undefined> {
    if (ctx.mode !== "tui") return;
    const session = ctx.sessionManager.getSessionFile();
    if (!session || !path.isAbsolute(session)) return;
    try {
      const { stdout } = await exec(launcher, ["pi-event", "--session", session, "--event", event], {
        timeout: 5000,
        maxBuffer: 32768,
      });
      return stdout.trim() || undefined;
    } catch (error) {
      if (!reportedFailure) {
        reportedFailure = true;
        console.error("Agent progress unavailable:", error);
      }
    }
  }

  pi.on("before_agent_start", async (_event, ctx) => {
    lastCheck = Date.now();
    const text = await check(ctx, "prompt");
    if (text) return { message: { customType: "agent-progress", content: text, display: false } };
  });

  pi.on("tool_result", async (event, ctx) => {
    if (ctx.mode !== "tui" || Date.now() - lastCheck < 60_000) return;
    if (JSON.stringify(event.input).includes("herdr-progress")) return;
    lastCheck = Date.now();
    const text = await check(ctx, "tool");
    if (text) return { content: [...event.content, { type: "text" as const, text }] };
  });
}
