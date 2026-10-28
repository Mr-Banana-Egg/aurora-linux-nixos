{ libfprint, omarchy-pkgs }:
libfprint.overrideAttrs (old: {
  patches =
    (old.patches or [ ])
    ++ map (p: "${omarchy-pkgs}/pkgbuilds/libfprint-git/aurora-${p}.patch") [
      "apple-sep"
      "touchid-retry"
      "touchid-lid-switch"
    ];
})
