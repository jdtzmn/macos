{ config, repoDir, ... }:
{
  # Shared, cross-project agent guidance. OpenCode references these files
  # directly via its `instructions` array; Pi's global AGENTS.md is generated
  # from personal-base.md + overlays/pi.md by `make agents` (see Makefile).
  xdg.configFile."agents".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/agents";
}
