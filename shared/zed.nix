{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [

    ];
    userSettings = {
      agent = {
        inline_assistant_model = {
          provider = "anthropic";
          model = "claude-sonnet-4-5-latest";
        };
        default_profile = "minimal";
        default_model = {
          provider = "anthropic";
          model = "claude-sonnet-4-5-latest";
        };
        model_parameters = [ ];
      };
      agent_servers = {
        OpenCode = {
          command = "opencode";
          args = [ "acp" ];
          env = { };
        };
      };
      vim_mode = true;
      relative_line_numbers = true;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      ui_font_size = 16;
      buffer_font_size = 12;
      theme = {
        mode = "dark";
        light = "Tokyo Night Light";
        dark = "Tokyo Night";
      };
      file_scan_inclusions = [
        ".env"
        ".env*"
      ];
    };
    userKeymaps = [
      {
        context = "Editor && vim_mode == insert";
        bindings = {
          "j k" = "vim::NormalBefore";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "cmd-?" = [
              "task::Spawn"
              {
                "task_name" = "Opencode";
                "reveal_target" = "center";
              }
          ];
        };
      }
    ];
    # To add once `userTasks` are supported
    #{
    #    "label": "Opencode",
    #    "command": "opencode",
    #    "shell": "system",
    #    "reveal_target": "center",
    #    "use_new_terminal": true,
    #    "show_command": false
    #}
  };
}
