{
  lib,
  pkgs,
  config,
  ...
}:
let
  vim-option = import ../shared-module/vim-option-with-key.nix;
in
{
  imports = [
    vim-option
    vim-option
  ];

  environment.systemPackages = lib.mkIf config._includeVim [ pkgs.vim ];
}
