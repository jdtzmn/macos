// Routes pi-claude-bridge's Claude Code child through billion-context's proxy.
//
// pi-claude-bridge hands requests to a Claude Code subprocess that dials Anthropic itself,
// so bili's in-process fetch patch never sees them. bili's pi extension publishes its proxy
// origin as BILLION_CONTEXT_PROXY, and Claude Code honours ANTHROPIC_BASE_URL, so pointing
// that at bili's documented `/bili/<upstream>` route puts the child's traffic on the proxy.
//
// Known upstream limitation (billion-context #3429): the bridge starts a fresh Claude Code
// session per pi start, so compression state resets on resume/reopen.
export default function (pi: any) {
	let routed: string | undefined;
	pi.on("before_agent_start", async (_event: unknown, ctx: any) => {
		if (ctx?.model?.provider !== "claude-bridge") {
			if (routed !== undefined && process.env.ANTHROPIC_BASE_URL === routed) {
				delete process.env.ANTHROPIC_BASE_URL;
			}
			routed = undefined;
			return;
		}
		const origin = process.env.BILLION_CONTEXT_PROXY;
		if (!origin) return;
		const current = process.env.ANTHROPIC_BASE_URL;
		// Leave a relay the user configured themselves alone.
		if (current && current !== routed) return;
		routed = `${origin}/bili/https://api.anthropic.com`;
		process.env.ANTHROPIC_BASE_URL = routed;
	});
}
