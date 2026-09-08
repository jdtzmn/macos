{ ... }:
{
  programs.direnv = {
    enable = true;

    # Declarative loader for per-computer overrides. `stdlib` is written to
    # ~/.config/direnv/direnvrc and runs for every .envrc evaluation, so any
    # allowed .envrc (including the empty ~/.envrc below) pulls in an unmanaged,
    # per-machine ~/.envrc.local when present. `source_env_if_exists` is a no-op
    # when the file is absent, so machines without one are unaffected.
    #
    # Put per-computer values (e.g. `export AWS_PROFILE=dev-admin`) in
    # ~/.envrc.local — it is intentionally NOT managed by Nix, so values stay
    # local to each machine and are never baked into the shared config.
    stdlib = ''
      source_env_if_exists "$HOME/.envrc.local"
    '';
  };

  # Empty, Nix-managed ~/.envrc so direnv activates under $HOME even when no
  # nearer .envrc exists; that activation is what triggers the stdlib loader
  # above to source ~/.envrc.local. Run `direnv allow ~` once per machine.
  home.file.".envrc".text = "";
}
