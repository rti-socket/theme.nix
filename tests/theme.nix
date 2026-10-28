{ lib }:
let
  evaluate = extra: (lib.evalModules {
    modules = [ ../theme.nix extra ];
  }).config.theme;
  light = evaluate { };
  dark = evaluate { theme.mode = "dark"; };
  paletteOverride = evaluate { theme.palette.cyan."3" = "#123456"; };
  roleOverride = evaluate ({ config, ... }: {
    theme.roles.primary = config.theme.palette.blue;
  });
  tokenOverride = evaluate { theme.colors.surface.bg = "#112233"; };
  legacyOverride = evaluate { theme.background = "#223344"; };
  invalid = value: !(builtins.tryEval (builtins.deepSeq (evaluate value) true)).success;
  expected = import ./legacy-light.nix;
in
assert builtins.deepSeq light true;
assert builtins.deepSeq dark true;
# Every old color attribute retains its value in the default light mode.
assert lib.all (name: light.${name} == expected.${name}) (builtins.attrNames expected);
assert light.palette == dark.palette;
assert light.roles == dark.roles;
assert light.colors.surface.bg == "#ffffff";
assert dark.colors.surface.bg == "#000000";
assert dark.colors.surface.fg == "#ffffff";
assert dark.colors.primary.fg == dark.roles.primary."7";
assert dark.colors.primary.bg == dark.roles.primary."1";
assert dark.background == dark.colors.surface.bg;
assert dark.termRed == dark.colors.terminal.normal.red;
assert dark.colors.overlay.selected.fg == "#000000";
assert paletteOverride.palette.cyan."7" == light.palette.cyan."7";
assert paletteOverride.roles.primary."3" == "#123456";
assert paletteOverride.colors.primary.fg == "#123456";
assert paletteOverride.foregroundCyan == "#123456";
assert roleOverride.colors.primary.fg == light.palette.blue."3";
assert roleOverride.colors.overlay.selected.bg == light.palette.blue."3";
assert tokenOverride.background == "#112233";
assert legacyOverride.colors.surface.bg == "#223344";
assert invalid { theme.mode = "sepia"; };
assert invalid { theme.colors.scrim.opacity = 1.1; };
assert invalid { theme.palette.cyan."3" = "blue"; };
assert invalid { theme.palette.cyan."10" = "#123456"; };
true
