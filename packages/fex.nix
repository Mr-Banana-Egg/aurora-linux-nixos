{ fex }:
fex.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ../patches/fex.diff ];
})
