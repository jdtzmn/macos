export default function (pi) {
  pi.on('session_start', async (event, ctx) => {
    if (event.reason !== 'startup') return
    const prefill = process.env.ORCA_PI_PREFILL
    if (!prefill) return
    delete process.env.ORCA_PI_PREFILL
    try {
      ctx.ui.setEditorText(prefill)
    } catch {}
  })
}
