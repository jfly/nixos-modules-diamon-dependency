{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../shared-module/vim-option.nix
    ../shared-module/vim-option.nix
  ];

  environment.systemPackages = lib.mkIf config._includeVim [ pkgs.vim ];
}
