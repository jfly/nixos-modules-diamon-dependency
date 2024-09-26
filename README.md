# Diamond dependencies with the nixpkgs module system

This flake declares 2 `nixosConfigurations`:

- `.#nixosConfigurations.use-module-binding`
- `.#nixosConfigurations.use-module-filepath`

They both include the `./vim-option.nix` module twice (simulating a "diamond
dependency"), but in different ways:

`use-module-filepath.nix`:
```nix
{
  imports = [
    ./vim-option.nix
    ./vim-option.nix
  ];

  ...
}
```

`use-module-binding.nix`:
```nix
let vim-option = import ./vim-option.nix;
in
{
  imports = [
    vim-option
    vim-option
  ];

  ...
}
```

This "double import via a binding" feels like something that's more likely to
happen as the nix flake ecosystem evolves: someday you're going to end up using
module A and module B where module B itself uses module A.

Note that `.#nixosConfigurations.use-module-filepath` evaluates fine:

```shell
$ nix eval .#nixosConfigurations.use-module-filepath.config.system.build.toplevel
trace: declaring _includeVim
«derivation /nix/store/dmmxnrhn6c6yibzlcdlwjb1i5akdcjsi-nixos-system-nixos-24.11.20240923.30439d9.drv»
```

However, `.#nixosConfigurations.use-module-binding` fails to evaluate:

```shell
$ nix eval .#nixosConfigurations.use-module-binding.config.system.build.toplevel
trace: declaring _includeVim
trace: declaring _includeVim
error:
       … while calling the 'head' builtin
         at /nix/store/p2hby44a0qzrnd1vxcpcgfav6160rmcv-source/lib/attrsets.nix:1575:11:
         1574|         || pred here (elemAt values 1) (head values) then
         1575|           head values
             |           ^
         1576|         else

       … while evaluating the attribute 'value'
         at /nix/store/p2hby44a0qzrnd1vxcpcgfav6160rmcv-source/lib/modules.nix:821:9:
          820|     in warnDeprecation opt //
          821|       { value = addErrorContext "while evaluating the option `${showOption loc}':" value;
             |         ^
          822|         inherit (res.defsFinal') highestPrio;

       … while evaluating the option `system.build.toplevel':

       … while evaluating definitions from `/nix/store/p2hby44a0qzrnd1vxcpcgfav6160rmcv-source/nixos/modules/system/activation/top-level.nix':

       … while evaluating the option `system.systemBuilderArgs':

       … while evaluating definitions from `/nix/store/p2hby44a0qzrnd1vxcpcgfav6160rmcv-source/nixos/modules/system/activation/activatable-system.nix':

       … while evaluating the option `system.activationScripts.etc.text':

       … while evaluating definitions from `/nix/store/p2hby44a0qzrnd1vxcpcgfav6160rmcv-source/nixos/modules/system/etc/etc-activation.nix':

       … while evaluating definitions from `/nix/store/p2hby44a0qzrnd1vxcpcgfav6160rmcv-source/nixos/modules/system/etc/etc.nix':

       … while evaluating the option `environment.etc.dbus-1.source':

       … while evaluating the option `environment.systemPackages':

       … while evaluating definitions from `/nix/store/vxrd24hjs9k56cjfhchyy57zs0n8kg84-source/use-module-binding.nix':

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error: The option `_includeVim' in `/nix/store/vxrd24hjs9k56cjfhchyy57zs0n8kg84-source/use-module-binding.nix' is already declared in `/nix/store/vxrd24hjs9k56cjfhchyy57zs0n8kg84-source/use-module-binding.nix'.
```
