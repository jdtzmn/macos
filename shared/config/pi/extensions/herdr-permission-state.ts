// Bridge permission-system's public prompt lifecycle to Herdr's agent-state integration.
// Kept separate from herdr-agent-state.ts because Herdr manages that extension.

const PERMISSION_PROMPT = "permissions:ui_prompt";
const PERMISSION_DECISION = "permissions:decision";
const HERDR_BLOCKED = "herdr:blocked";

export default function (pi: any) {
  const pendingPrompts = new Set<string>();

  pi.events.on(PERMISSION_PROMPT, (event: any) => {
    const requestId = event?.requestId;
    if (typeof requestId !== "string" || pendingPrompts.has(requestId)) {
      return;
    }

    pendingPrompts.add(requestId);
    const surface = typeof event.surface === "string" ? event.surface : null;
    pi.events.emit(HERDR_BLOCKED, {
      active: true,
      label: surface ? `Permission required: ${surface}` : "Permission required",
    });
  });

  pi.events.on(PERMISSION_DECISION, (event: any) => {
    const requestId = event?.requestId;
    if (typeof requestId !== "string" || !pendingPrompts.delete(requestId)) {
      return;
    }

    pi.events.emit(HERDR_BLOCKED, { active: false });
  });
}
