{
  lib,
  pkgs,
  config,
  ...
}:
let
  vim-option = import ./vim-option.nix;
in
{
  imports = [
    vim-option
    vim-option
  ];

  environment.systemPackages = lib.mkIf config._includeVim [ pkgs.vim ];
}
