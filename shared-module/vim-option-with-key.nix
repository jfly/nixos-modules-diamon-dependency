{ lib, ... }:
{
  key = "is this a best practice, or is this a workaround? caught in a landslide, no escape from reality";
  options._includeVim = builtins.trace "declaring _includeVim" (
    lib.mkOption {
      internal = true;
      default = false;
    }
  );

  # Interestingly, this does not reproduce the same issue:
  # options._includeVim = builtins.trace "declaring _includeVim" (lib.mkOption {internal = true;});
  # config._includeVim = true;
}
