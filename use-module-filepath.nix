{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./vim-option.nix
    ./vim-option.nix
  ];

  environment.systemPackages = lib.mkIf config._includeVim [ pkgs.vim ];
}
