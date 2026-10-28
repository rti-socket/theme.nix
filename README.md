# theme.nix

NixOS module exporting color definitions and sizes for theming applications consistently.

Import `inputs.theme.nixosModules.theme` into your NixOS configuration, then select
the semantic color mappings with `theme.mode = "light";` (the default) or
`theme.mode = "dark";`. This is an evaluation-time choice: rebuild to switch.
Applications use the same tokens in either mode:

```nix
{ config, ... }:
{
  theme.mode = "dark";

  # Example application values:
  # background = config.theme.colors.surface.bg;
  # foreground = config.theme.colors.surface.fg;
}
```

Colors have three layers:

| Layer | Example | Meaning |
| --- | --- | --- |
| Palette | `theme.palette.cyan."3"` | Fixed shade, independent of mode |
| Role ramp | `theme.roles.primary."3"` | Palette shade assigned to a semantic role |
| UI token | `theme.colors.primary.fg` | Color chosen for a particular use and mode |

Palette shade numbers run from **0 darkest to 9 lightest** and never reverse in
dark mode. Gaps are intentional; spacing does not imply equal perceptual steps.
`neutral` covers black through white. The six hue ramps currently provide shades
`1`, `3`, `5`, `7`, and `9`; the built-in mappings require those shades. Additional
hues and shades can be added without creating new UI tokens automatically.

`primary`, `secondary`, and `urgent` default to the cyan, magenta, and red ramps.
Customize individual palette shades or assign a different role family:

```nix
{ config, ... }:
{
  theme.palette.cyan."3" = "#176f80";
  theme.roles.primary = config.theme.palette.blue;
  theme.colors.surface.bg = "#101418";
}
```

Semantic tokens are grouped by use:

| Token group under `theme.colors` | Fields |
| --- | --- |
| `surface` | `bg`, `bgAlt`, `bgSubtle`, `border`, `fg`, `fgMuted`, `fgSubtle`, `fgDisabled` |
| `surface.selected`, `surface.hover` | `bg`, `fg` for rows/items |
| `overlay` | `bg`, `bgAlt`, `fg`, `fgMuted` for menus/popups |
| `overlay.selected`, `overlay.hover` | `bg`, `fg` within the overlay |
| `selection` | `bg`, `fg` for selected text |
| `focus` | `border` for keyboard focus |
| `scrim` | `color`, `opacity` for dimming behind a modal |
| `primary`, `secondary`, `urgent` | `fg`, `bg`, `solid`, `onSolid` |
| `accents.<hue>` | The same four fields for each palette hue |
| `terminal.normal`, `terminal.bright` | Eight named ANSI slots each |

Use `fg` on `bg`, and `onSolid` on `solid`. Muted and disabled colors are for
lower-emphasis content; assess contrast for the actual application and font size.
The light mappings preserve the previous palette. The dark mappings add dark
tinted backgrounds and use lighter accent foregrounds. Overlay surfaces stay dark
in both modes, with a separately mapped selection pair. Hover, item selection,
text selection, and focus remain separate tokens even where values coincide.
Scrim opacity is a number from 0 to 1; application adapters handle alpha encoding.

The old flat attributes remain writable aliases, and their default light values
are unchanged. For example, `theme.background` aliases
`theme.colors.surface.bg`, `theme.foregroundOverlaySelect` aliases
`theme.colors.overlay.selected.fg`, and `theme.termRed` aliases
`theme.colors.terminal.normal.red`. Prefer the structured tokens for new consumers.
Overrides propagate through the new hierarchy; set a palette shade or role to
change all its derived uses, or a UI token to change just that use. Legacy
`light*`/`bright*` attributes alias fixed palette shades `7`/`5` respectively.

Run `nix flake check` to evaluate both modes, compare all legacy light color
values, verify override propagation, and check rejection of invalid option values.

<p align="center">
  <img src="./screenshot.png" alt="Neovim screenshot">
</p>
