{
  home.file.".local/bin/remote" = {
    executable = true;
    text = builtins.readFile ./config/remote;
  };
}
