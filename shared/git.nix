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

      core = {
        pager = "delta";
      };

      delta = {
        navigate = true;
        "side-by-side" = true;
        "line-numbers" = true;
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      user = {
        name = gitUserName;
        email = gitUserEmail;
      };
    };
  };
}
