## A Flake that ports omacom's kernel and packages to NixOS
To use it simply add 
```aurora-linux-nixos.url = "github:Mr-Banana-Egg/aurora-linux-nixos";```
 to your flake.nix (you can only use this repository with flakes).
Then import it using `imports = [aurora-linux-nixos.nixosModules.default];`

Now you have accses to the following options:
```
hardware.aurora.kernel.enable = true; # Enables the custom aurora kernel.
hardware.aurora.fingerprint.enable = true; # Fingerprint support for TOUCH-ID, enable to get fprintd all set up. NEEDS hardware.aurora.kernel.enable TO BE SET TO TRUE.
#hardware.aurora.binaryCache.enable = false; # By default the flake uses binary cache to turn it off uncomment this line.
hardware.asahi = {
      enable = true;
      # You still need to enable nixos-apple-silicon, all options can be used =)
      #...
};
```
After adding the options above rebuild NixOS with this command if you want to use binary cache, this is needed because NixOS adds the binary cache that is declared in my module after the rebuild so during the first rebuild of NixOS you need to directly specify the binary cache.
```
sudo nixos-rebuild switch --flake . \
        --option extra-substituters https://aurora-linux-nixos.cachix.org \
        --option extra-trusted-public-keys "aurora-linux-nixos.cachix.org-1:GLmR9BtSA8OY7UZMUCG9eMaWZEvXJCR4b/pYH4dhX+E="
```
There are also standalone packages to be used, most are used with the `hardware.aurora` options. The only package for users to use is the userpages package, it allows users to use 4k page sizes on 16k page system (NEEDS `hardware.aurora.kernel.enable` TO BE TRUE).
