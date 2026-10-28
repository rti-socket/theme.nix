{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.theme;
  color = types.strMatching "#[0-9a-fA-F]{6}";
  ramp = types.addCheck (types.attrsOf color)
    (shades: lib.all (shade: builtins.match "[0-9]" shade != null) (builtins.attrNames shades));
  colorOption = description: mkOption { type = color; inherit description; };
  fields = names: lib.genAttrs names (name: colorOption "Color for ${name}.");
  group = options: mkOption { type = types.submodule { inherit options; }; };
  pair = group (fields [ "bg" "fg" ]);
  accent = group (fields [ "fg" "bg" "solid" "onSolid" ]);
  hues = [ "red" "green" "yellow" "blue" "magenta" "cyan" ];
  capitalize = name: lib.toUpper (builtins.substring 0 1 name)
    + builtins.substring 1 (-1) name;
  # Explicit color type also supports targets inside submodules and attrsOf ramps.
  alias = old: new: { config, options, ... }: {
    options.theme.${old} = mkOption {
      type = color;
      description = "Compatibility alias for theme.${lib.concatStringsSep "." new}.";
      apply = _: lib.getAttrFromPath ([ "theme" ] ++ new) config;
    };
    config = lib.mkAliasAndWrapDefsWithPriority
      (lib.setAttrByPath ([ "theme" ] ++ new)) options.theme.${old};
  };
  aliases = {
    foreground = [ "colors" "surface" "fg" ];
    foreground2 = [ "colors" "surface" "fgMuted" ];
    foreground3 = [ "colors" "surface" "fgSubtle" ];
    foreground4 = [ "colors" "surface" "fgDisabled" ];
    background = [ "colors" "surface" "bg" ];
    background2 = [ "colors" "surface" "bgAlt" ];
    background3 = [ "colors" "surface" "bgSubtle" ];
    background4 = [ "colors" "surface" "border" ];
    foregroundSelect = [ "colors" "surface" "selected" "fg" ];
    backgroundSelect = [ "colors" "surface" "selected" "bg" ];
    foregroundOverlay = [ "colors" "overlay" "fg" ];
    foregroundOverlay2 = [ "colors" "overlay" "fgMuted" ];
    backgroundOverlay = [ "colors" "overlay" "bg" ];
    backgroundOverlay2 = [ "colors" "overlay" "bgAlt" ];
    foregroundOverlaySelect = [ "colors" "overlay" "selected" "fg" ];
    backgroundOverlaySelect = [ "colors" "overlay" "selected" "bg" ];
    primary = [ "colors" "primary" "solid" ];
    secondary = [ "colors" "secondary" "solid" ];
    urgent = [ "colors" "urgent" "solid" ];
    backgroundPrimary = [ "colors" "primary" "fg" ];
    backgroundSecondary = [ "colors" "secondary" "fg" ];
    backgroundUrgent = [ "colors" "urgent" "fg" ];
  };
in
{
  imports = lib.mapAttrsToList alias aliases
    ++ lib.concatMap (hue: [
      (alias "foreground${capitalize hue}" [ "colors" "accents" hue "fg" ])
      (alias "background${capitalize hue}" [ "colors" "accents" hue "bg" ])
      (alias "light${capitalize hue}" [ "palette" hue "7" ])
      (alias "bright${capitalize hue}" [ "palette" hue "5" ])
    ]) hues
    ++ lib.concatMap (hue: [
      (alias "term${capitalize hue}" [ "colors" "terminal" "normal" hue ])
      (alias "termBright${capitalize hue}" [ "colors" "terminal" "bright" hue ])
    ]) ([ "black" "white" ] ++ hues);

  options.theme = {
    mode = mkOption {
      type = types.enum [ "light" "dark" ];
      default = "light";
      description = "Select semantic colors at Nix evaluation time.";
    };
    palette = mkOption {
      type = types.attrsOf ramp;
      description = "Hue ramps with sparse shades 0 (darkest) through 9 (lightest), independent of mode.";
    };
    roles = group (lib.genAttrs [ "primary" "secondary" "urgent" ] (name: mkOption {
      type = ramp;
      description = "Mode-independent palette ramp for the ${name} role.";
    }));
    colors = group {
      surface = group ((fields [
        "bg" "bgAlt" "bgSubtle" "border" "fg" "fgMuted" "fgSubtle" "fgDisabled"
      ]) // { selected = pair; hover = pair; });
      overlay = group ((fields [ "bg" "bgAlt" "fg" "fgMuted" ]) // {
        selected = pair;
        hover = pair;
      });
      selection = pair;
      focus = group (fields [ "border" ]);
      scrim = group {
        color = colorOption "Color behind modal surfaces.";
        opacity = mkOption {
          type = types.numbers.between 0 1;
          description = "Scrim opacity, kept separate from renderer-specific color syntax.";
        };
      };
      primary = accent;
      secondary = accent;
      urgent = accent;
      accents = group (lib.genAttrs hues (_: accent));
      terminal = group {
        normal = group (fields ([ "black" "white" ] ++ hues));
        bright = group (fields ([ "black" "white" ] ++ hues));
      };
    };
    borderRadius = mkOption { type = types.int; default = 8; };
    borderWidth = mkOption { type = types.int; default = 4; };
    gaps = mkOption { type = types.int; default = 16; };
    wallpaper = mkOption {
      type = types.path;
      default = ./wallpapers/geometric-abstract-3840x2160-23187.jpg;
    };
    cursorTheme = mkOption { type = types.str; default = "Adwaita"; };
    cursorSize = mkOption { type = types.int; default = 24; };
  };

  config.theme = {
    palette = lib.mapAttrsRecursive (_: value: lib.mkDefault value) (import ./palette.nix);
    roles = lib.mapAttrsRecursive (_: value: lib.mkDefault value) {
      primary = cfg.palette.cyan;
      secondary = cfg.palette.magenta;
      urgent = cfg.palette.red;
    };
    # Defaults at leaf level allow both new tokens and legacy aliases to be overridden.
    colors = lib.mapAttrsRecursive (_: value: lib.mkDefault value) (import ./colors.nix {
      inherit (cfg) palette roles mode;
    });
  };
}
