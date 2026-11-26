// Routes the Claude Agent provider through billion-context's proxy (OpenCode port of
// shared/config/pi/extensions/bili-claude-route.ts).
//
// Claude Agent runs a Claude Code subprocess that calls Anthropic itself, so the
// billion-context plugin's in-process fetch patch never sees it (billion-context#6816).
// OpenCode passes the provider's settings.baseURL to that subprocess as
// ANTHROPIC_BASE_URL, and the billion-context plugin publishes its live proxy origin as
// BILLION_CONTEXT_PROXY, so point the provider at bili's `/bili/<upstream>` route.
// The proxy port changes between runs, which is why this is set at runtime instead of
// in opencode.jsonc.

const PROVIDER_ID = "claude-agent";
const UPSTREAM = "https://api.anthropic.com";
const POLL_MS = 2000;

// Inline mode only intercepts fetch inside OpenCode; a subprocess can't reach it.
function proxyRoute() {
  const origin = process.env.BILLION_CONTEXT_PROXY;
  if (!origin || !/^http:\/\/(127\.0\.0\.1|localhost):\d+$/.test(origin)) return undefined;
  return `${origin}/bili/${UPSTREAM}`;
}

export default {
  id: "bili-claude-route",
  async setup(ctx) {
    await ctx.provider.transform((editor) => {
      const route = proxyRoute();
      if (route === undefined || editor.get(PROVIDER_ID) === undefined) return;
      editor.update(PROVIDER_ID, (provider) => {
        provider.settings ??= {};
        // Leave a relay the user configured themselves alone.
        if (provider.settings.baseURL === undefined) provider.settings.baseURL = route;
      });
    });

    // The proxy starts after plugins load and may respawn on a new port, or go away
    // (bili unsets the variable), so re-apply whenever the published origin changes.
    let seen = proxyRoute();
    const timer = setInterval(() => {
      const route = proxyRoute();
      if (route === seen) return;
      seen = route;
      ctx.provider.reload().catch(() => {});
    }, POLL_MS);
    timer.unref?.();
    return () => clearInterval(timer);
  },
};
