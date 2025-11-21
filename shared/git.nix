{ ... }:
let
  gitSigningKey = builtins.getEnv "GIT_SIGNING_KEY";
in
{
  programs.git = {
    enable = true;

    signing = {
      format = "ssh";
      signByDefault = true;
      key = gitSigningKey;
    };

    settings = {
      alias = {
        s = "status";
      };

      user = {
        name = "Jacob Daitzman";
        email = "jdtzmn@gmail.com";
      };
    };
  };
}
