{m1n1}: m1n1.overrideAttrs (old: {patches = (old.patches or [ ]) ++ [ ../patches/m1n1.diff ];})
