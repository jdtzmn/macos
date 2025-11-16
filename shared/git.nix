{ pkgs, config, ... }:
let
  gitSigningKey = builtins.getEnv "GIT_SIGNING_KEY";
in
{
  programs.git = {
    enable = true;
    userName = "Jacob Daitzman";
    userEmail = "jdtzmn@gmail.com";

    aliases = {
      s = "status";
    };
  };
}
