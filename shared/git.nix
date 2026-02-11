{ ... }:
let
  gitSigningKey = builtins.getEnv "GIT_SIGNING_KEY";
  gitUserName = builtins.getEnv "GIT_USER_NAME";
  gitUserEmail = builtins.getEnv "GIT_USER_EMAIL";
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
        name = gitUserName;
        email = gitUserEmail;
      };
    };
  };
}
