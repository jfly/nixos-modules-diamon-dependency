EDIT: I found <https://github.com/NixOS/nixpkgs/issues/215496> which describes
this problem.

# Diamond dependencies with the nixpkgs module system

This flake declares 3 `nixosConfigurations`. They all include a nixos module
module twice (simulating a "diamond dependency"), but in different ways:

- `.#nixosConfigurations.use-module-filepath`: References the module by path twice.
- `.#nixosConfigurations.use-module-binding`: Imports the module, stashes it in a `let`, and then uses it twice.
- `.#nixosConfigurations.use-module-binding-with-key`: Like
  `use-module-binding`, but uses a different module that declares a `key`.

This "double import via a binding" feels like something that's more likely to
happen as the nix flake ecosystem evolves: someday you're going to end up using
module A and module B where module B itself uses module A.

I don't know if the fix for this is for all modules to declare a human-chosen
key, or if this is some not-yet-robustly-solved problem. That might be what the
discussion over on
<https://github.com/NixOS/nixpkgs/pull/230588#discussion_r1334294197> is
talking about.

## Demo

### `.#nixosConfigurations.use-module-filepath` works:

```shell
$ nix eval .#nixosConfigurations.use-module-filepath.config.system.build.toplevel
trace: declaring _includeVim
«derivation /nix/store/dmmxnrhn6c6yibzlcdlwjb1i5akdcjsi-nixos-system-nixos-24.11.20240923.30439d9.drv»
```

### `.#nixosConfigurations.use-module-binding` fails to evaluate:

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

### `.#nixosConfigurations.use-module-binding-with-key` works:

```shell
$ nix eval .#nixosConfigurations.use-module-binding-with-key.config.system.build.toplevel
trace: declaring _includeVim
«derivation /nix/store/dmmxnrhn6c6yibzlcdlwjb1i5akdcjsi-nixos-system-nixos-24.11.20240923.30439d9.drv»
```
