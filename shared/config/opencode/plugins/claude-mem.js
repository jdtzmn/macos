// Claude-mem persistent memory plugin for OpenCode.
// Ports @bloodf/opencode-claude-mem without auto-setup or file mutation.
// Connects to the claude-mem worker running on localhost:37777.
// MCP tools, commands, and skills are declared statically in the repo.

import { basename } from "path";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const WORKER_PORT = 37777;
const WORKER_HOST = "localhost";
const DEFAULT_TIMEOUT_MS = 2000;
const STATUS_TIMEOUT_MS = 500;
const MAX_OUTPUT_BYTES = 50_000;
const MAX_TAG_REPLACEMENTS = 100;

const SUMMARY_INTERVAL = 3; // Send a mid-session summary every N prompts

const SKIP_TOOLS = new Set([
  "todowrite",
  "askuserquestion",
  "listmcpresourcestool",
  "slashcommand",
  "skill",
  "listmcptools",
  "getmcpresource",
]);

// ---------------------------------------------------------------------------
// Tag stripping utilities
// ---------------------------------------------------------------------------

const PRIVATE_TAG_REGEX = /<private>[\s\S]*?<\/private>/g;
const CONTEXT_TAG_REGEX = /<claude-mem-context>[\s\S]*?<\/claude-mem-context>/g;

function stripMemoryTagsFromText(text) {
  if (!text) return text;
  let result = text;
  let count = 0;
  while (count < MAX_TAG_REPLACEMENTS && PRIVATE_TAG_REGEX.test(result)) {
    PRIVATE_TAG_REGEX.lastIndex = 0;
    result = result.replace(PRIVATE_TAG_REGEX, "");
    count++;
  }
  PRIVATE_TAG_REGEX.lastIndex = 0;
  while (count < MAX_TAG_REPLACEMENTS && CONTEXT_TAG_REGEX.test(result)) {
    CONTEXT_TAG_REGEX.lastIndex = 0;
    result = result.replace(CONTEXT_TAG_REGEX, "");
    count++;
  }
  CONTEXT_TAG_REGEX.lastIndex = 0;
  return result.trim();
}

function stripFromObject(obj) {
  if (typeof obj === "string") return stripMemoryTagsFromText(obj);
  if (Array.isArray(obj)) return obj.map(stripFromObject);
  if (obj !== null && typeof obj === "object") {
    const result = {};
    for (const [k, v] of Object.entries(obj)) {
      result[k] = stripFromObject(v);
    }
    return result;
  }
  return obj;
}

function stripMemoryTagsFromJson(jsonString) {
  if (!jsonString) return jsonString;
  try {
    const parsed = JSON.parse(jsonString);
    return JSON.stringify(stripFromObject(parsed));
  } catch {
    return stripMemoryTagsFromText(jsonString);
  }
}

function safeParseJson(str) {
  try {
    return JSON.parse(str);
  } catch {
    return str;
  }
}

// ---------------------------------------------------------------------------
// ClaudeMemClient
// ---------------------------------------------------------------------------

class ClaudeMemClient {
  constructor(port = WORKER_PORT, timeout = DEFAULT_TIMEOUT_MS, log = () => {}, host = WORKER_HOST) {
    this.baseUrl = `http://${host}:${port}`;
    this.timeout = timeout;
    this.log = log;
  }

  async healthCheck(retries = 3) {
    for (let i = 0; i < retries; i++) {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), this.timeout);
      try {
        const res = await fetch(`${this.baseUrl}/health`, { signal: controller.signal });
        if (res.ok) {
          const payload = await res.json();
          return payload.status === "ok";
        }
      } catch {
        if (i < retries - 1) {
          await new Promise((resolve) => setTimeout(resolve, 1000));
        }
      } finally {
        clearTimeout(timer);
      }
    }
    return false;
  }

  async getContext(projectName) {
    const path = `/api/context/inject?project=${encodeURIComponent(projectName)}`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeout);
    try {
      const res = await fetch(`${this.baseUrl}${path}`, { signal: controller.signal });
      if (!res.ok) return null;
      const text = await res.text();
      if (!text.trim()) return null;
      return { context: text, projectName };
    } catch (err) {
      this.log(`[claude-mem] GET ${path} failed: ${err}`);
      return null;
    } finally {
      clearTimeout(timer);
    }
  }

  async getMemoryStatus() {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), STATUS_TIMEOUT_MS);
    try {
      const res = await fetch(`${this.baseUrl}/health`, { signal: controller.signal });
      if (res.ok) {
        const payload = await res.json();
        if (payload.status === "ok") {
          return { connected: true, version: payload.version, workerUrl: this.baseUrl };
        }
      }
      return { connected: false, workerUrl: this.baseUrl };
    } catch {
      return { connected: false, workerUrl: this.baseUrl };
    } finally {
      clearTimeout(timer);
    }
  }

  async initSession(payload) {
    await this.safePost("/api/sessions/init", payload);
  }

  async sendObservation(payload) {
    await this.safePost("/api/sessions/observations", payload);
  }

  async sendSummary(payload) {
    await this.safePost("/api/sessions/summarize", payload);
  }

  async completeSession(payload) {
    await this.safePost("/api/sessions/complete", payload);
  }

  async safePost(path, body) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeout);
    try {
      await fetch(`${this.baseUrl}${path}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: controller.signal,
      });
    } catch (err) {
      this.log(`[claude-mem] POST ${path} failed: ${err}`);
    } finally {
      clearTimeout(timer);
    }
  }
}

// ---------------------------------------------------------------------------
// Plugin
// ---------------------------------------------------------------------------

/** @type {import("/Users/jacob/.cache/opencode/node_modules/@opencode-ai/plugin/dist/index.d.ts").Plugin} */
export const ClaudeMemPlugin = async ({ client, project, directory }) => {
  const projectName =
    typeof project === "object" && project !== null && typeof project.worktree === "string" && project.worktree.length > 0
      ? basename(project.worktree)
      : basename(directory);

  let logReady = false;
  const log = (msg, level = "info") => {
    if (!logReady) return;
    try {
      client.app.log({ body: { service: "claude-mem", message: `[claude-mem] ${msg}`, level } });
    } catch {}
  };

  const mem = new ClaudeMemClient(WORKER_PORT, DEFAULT_TIMEOUT_MS, log, WORKER_HOST);

  const state = {
    sessionId: "",
    promptNumber: 0,
    lastSummaryPrompt: 0,
    lastUserMessage: "",
    lastAssistantMessage: "",
    summarySent: false,
    isWorkerRunning: false,
  };

  // Detect worker
  state.isWorkerRunning = await mem.healthCheck(1).catch(() => false);

  logReady = true;

  if (state.isWorkerRunning) {
    log(`Connected to claude-mem worker at ${mem.baseUrl}`);
  } else {
    log("claude-mem worker not running. Memory features disabled. Start with: claude-mem start", "warn");
  }

  return {
    // -------------------------------------------------------------------------
    // Session lifecycle
    // -------------------------------------------------------------------------
    event: async ({ event }) => {
      // Resolve session ID from multiple possible locations across opencode versions
      const resolveEventSessionId = () =>
        event.properties?.sessionID ??
        event.properties?.info?.id ??
        event.properties?.id ??
        state.sessionId;

      if (event.type === "session.created") {
        const newSessionId = resolveEventSessionId();
        if (state.sessionId && state.sessionId !== newSessionId) {
          void mem.completeSession({ contentSessionId: state.sessionId });
        }
        state.sessionId = newSessionId ?? "";
        state.summarySent = false;
        state.promptNumber = 0;
        state.lastSummaryPrompt = 0;
        state.lastUserMessage = "";
        state.lastAssistantMessage = "";
        log(`Session created: ${state.sessionId}`);
      }

      if (event.type === "session.deleted") {
        const sessionId = resolveEventSessionId();
        if (sessionId) {
          if (!state.summarySent) {
            void mem.sendSummary({
              contentSessionId: sessionId,
              last_assistant_message: state.lastAssistantMessage || undefined,
            });
            state.summarySent = true;
          }
          void mem.completeSession({ contentSessionId: sessionId });
        }
      }

      // session.idle → send summary
      if (event.type === "session.idle") {
        const sessionId = resolveEventSessionId();
        if (!sessionId || state.summarySent) return;
        void mem.sendSummary({
          contentSessionId: sessionId,
          last_assistant_message: state.lastAssistantMessage || undefined,
        });
        state.summarySent = true;
      }
    },

    // -------------------------------------------------------------------------
    // Capture user prompt
    // -------------------------------------------------------------------------
    "chat.message": async (input, output) => {
      // Resolve session ID from multiple possible locations
      const sessionID =
        input?.sessionID ??
        input?.message?.sessionID ??
        output?.message?.sessionID;

      if (!sessionID) return;

      // Only track the primary (root) session — set it on first message
      if (!state.sessionId) {
        state.sessionId = sessionID;
      }
      // Skip messages from a different session (e.g. child agents with different IDs)
      if (sessionID !== state.sessionId) return;

      const parts = output?.parts ?? [];
      const textContent = parts
        .filter((p) => p?.type === "text")
        .map((p) => p.text ?? "")
        .join("\n");

      const cleanText = stripMemoryTagsFromText(textContent);
      if (!cleanText.trim()) return;

      state.lastUserMessage = cleanText;
      state.promptNumber += 1;
      // Reset summarySent so periodic summaries can fire again for this new prompt
      state.summarySent = false;

      log(`Prompt ${state.promptNumber} captured (session: ${sessionID})`);

      void mem.initSession({
        contentSessionId: sessionID,
        project: projectName,
        prompt: cleanText,
      });
    },

    // -------------------------------------------------------------------------
    // Save tool observation
    // -------------------------------------------------------------------------
    "tool.execute.after": async (input, output) => {
      if (SKIP_TOOLS.has((input.tool ?? "").toLowerCase())) return;
      const sessionID = input.sessionID ?? state.sessionId;
      if (!sessionID) return;

      let toolOutput = output.output ?? "";
      if (toolOutput.length > MAX_OUTPUT_BYTES) {
        toolOutput = toolOutput.slice(0, MAX_OUTPUT_BYTES) + "\n[truncated]";
      }

      let inputText;
      try {
        inputText = JSON.stringify(input.args ?? {});
      } catch {
        inputText = "[unserializable input]";
      }
      if (inputText.length > MAX_OUTPUT_BYTES) {
        inputText = inputText.slice(0, MAX_OUTPUT_BYTES) + "\n[truncated]";
      }

      void mem.sendObservation({
        contentSessionId: sessionID,
        tool_name: input.tool,
        tool_input: safeParseJson(stripMemoryTagsFromJson(inputText)),
        tool_response: stripMemoryTagsFromText(toolOutput),
        cwd: directory || undefined,
        last_user_message: state.lastUserMessage || undefined,
        last_assistant_message: state.lastAssistantMessage || undefined,
        prompt_number: state.promptNumber > 0 ? state.promptNumber : undefined,
      });

      // Periodic mid-session summary every SUMMARY_INTERVAL prompts
      if (
        state.promptNumber > 0 &&
        state.promptNumber - state.lastSummaryPrompt >= SUMMARY_INTERVAL
      ) {
        state.lastSummaryPrompt = state.promptNumber;
        void mem.sendSummary({
          contentSessionId: sessionID,
          last_assistant_message: state.lastAssistantMessage || undefined,
        });
        log(`Mid-session summary queued at prompt ${state.promptNumber}`);
      }
    },

    // -------------------------------------------------------------------------
    // Inject memory context into system prompt
    // -------------------------------------------------------------------------
    "experimental.chat.system.transform": async (input, output) => {
      try {
        const result = await mem.getContext(projectName);
        if (result?.context) {
          output.system.push(
            ["## Claude-Mem Persistent Memory", "", result.context, "", `Memory viewer: http://${WORKER_HOST}:${WORKER_PORT}`].join("\n"),
          );
        }

        const status = await mem.getMemoryStatus();
        let statusBlock;
        if (status.connected) {
          const version = status.version ? ` ${status.version}` : "";
          statusBlock = [
            "## 🧠 Claude-Mem Status",
            `- Connection: ✓ Active (${status.workerUrl})`,
            `- Worker Version:${version}`,
            "- Available Commands: /mem-search, /mem-status, /mem-timeline",
            `- Memory Viewer: ${status.workerUrl}`,
          ].join("\n");
        } else {
          statusBlock = [
            "## 🧠 Claude-Mem Status",
            "- Connection: ✗ Disconnected",
            "- Memory features unavailable. Start worker: /mem-worker-start",
          ].join("\n");
        }
        output.system.unshift(statusBlock);
      } catch {}
    },

    // -------------------------------------------------------------------------
    // Inject memory context on compaction (survives context window reset)
    // -------------------------------------------------------------------------
    "experimental.session.compacting": async (input, output) => {
      try {
        const result = await mem.getContext(projectName);
        if (result?.context) {
          output.context.push(
            ["## Claude-Mem Persistent Memory (survives compaction)", "", result.context].join("\n"),
          );
        }
      } catch {}
    },

    // -------------------------------------------------------------------------
    // Log slash command usage as an observation
    // -------------------------------------------------------------------------
    "command.execute.before": async (input, _output) => {
      const sessionID = input.sessionID ?? state.sessionId;
      if (!sessionID || !input.command) return;

      let argumentsText;
      try {
        argumentsText = JSON.stringify(input.arguments ?? {});
      } catch {
        argumentsText = "[unserializable input]";
      }

      void mem.sendObservation({
        contentSessionId: sessionID,
        tool_name: `command:${input.command}`,
        tool_input: safeParseJson(stripMemoryTagsFromJson(argumentsText)),
        tool_response: `Slash command executed: /${input.command}`,
      });
    },
  };
};
