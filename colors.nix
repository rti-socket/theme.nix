# Pure semantic mapping. Palette and role shade numbers never change with mode.
{ palette, roles, mode }:
let
  p = palette;
  dark = mode == "dark";
  ramps = builtins.listToAttrs (map (name: { inherit name; value = p.${name}; })
    [ "red" "green" "yellow" "blue" "magenta" "cyan" ]);
  accent = ramp: {
    fg = ramp.${if dark then "7" else "3"};
    bg = ramp.${if dark then "1" else "9"};
    solid = ramp."5";
    onSolid = p.neutral."0";
  };
  accents = builtins.mapAttrs (_: accent) ramps;
  terminalHues = builtins.mapAttrs (_: ramp: ramp.${if dark then "7" else "3"})
    ramps;
  terminalBright = builtins.mapAttrs (_: ramp: ramp."5")
    ramps;
in
{
  surface = {
    bg = p.neutral.${if dark then "0" else "9"};
    bgAlt = p.neutral.${if dark then "1" else "8"};
    bgSubtle = p.neutral.${if dark then "2" else "7"};
    border = p.neutral.${if dark then "4" else "6"};
    fg = p.neutral.${if dark then "9" else "0"};
    fgMuted = p.neutral.${if dark then "6" else "2"};
    fgSubtle = p.neutral.${if dark then "5" else "4"};
    fgDisabled = p.neutral.${if dark then "4" else "5"};
    selected = {
      bg = p.neutral.${if dark then "2" else "7"};
      fg = p.neutral.${if dark then "9" else "0"};
    };
    hover = {
      bg = p.neutral.${if dark then "1" else "8"};
      fg = p.neutral.${if dark then "9" else "0"};
    };
  };
  # Menus/popups remain dark in both modes; selection belongs to this surface.
  overlay = {
    bg = p.neutral.${if dark then "1" else "2"};
    bgAlt = p.neutral.${if dark then "2" else "4"};
    fg = p.neutral."9";
    fgMuted = p.neutral."7";
    selected = {
      bg = roles.primary.${if dark then "7" else "3"};
      fg = p.neutral.${if dark then "0" else "9"};
    };
    hover = {
      bg = p.neutral.${if dark then "2" else "4"};
      fg = p.neutral."9";
    };
  };
  # Text selection is independent of selected rows and keyboard focus.
  selection = {
    bg = roles.primary.${if dark then "3" else "9"};
    fg = p.neutral.${if dark then "9" else "0"};
  };
  focus.border = roles.primary.${if dark then "7" else "3"};
  scrim = { color = p.neutral."0"; opacity = 0.5; };
  primary = accent roles.primary;
  secondary = accent roles.secondary;
  urgent = accent roles.urgent;
  inherit accents;
  # ANSI slots are explicit mappings, independent of literal palette black/white.
  terminal = {
    normal = terminalHues // {
      black = p.neutral.${if dark then "0" else "9"};
      white = p.neutral.${if dark then "9" else "0"};
    };
    bright = terminalBright // {
      black = p.neutral."4";
      white = p.neutral.${if dark then "7" else "4"};
    };
  };
}
