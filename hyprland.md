# Hyprland Configuration Reference

Setup: CachyOS, NVIDIA RTX 4070 Ti SUPER + Intel UHD 770 (hybrid), single ultrawide 3440x1440@165.
Config lives in `~/dotfiles/hyprland/.config/hypr/` (stowed to `~/.config/hypr/`).

## Config file layout

| File | Purpose |
|------|---------|
| `hyprland.conf` | Main entry point — monitor, env vars, startup, input, sources |
| `mocha.conf` | Catppuccin Mocha color variables |
| `layouts.conf` | `general {}` and `master {}` blocks |
| `decorations.conf` | `decoration {}`, `group {}`, `animations {}` |
| `keybinds.conf` | All keybindings |
| `windowrules.conf` | Window rules (new block syntax, see below) |

## Window rules — new block syntax (Hyprland 0.41+)

`windowrulev2` is **deprecated** as of 0.41 and **errors** as of ~0.46+. Use the block syntax:

```
windowrule {
    name = descriptive-name   # optional but helpful
    match:class = ^(regex)$   # window class matcher
    match:title = ^(regex)$   # window title matcher (can combine with class)
    property = value
}
```

Multiple matchers in one block are ANDed together.

### Matchers

| Old (windowrulev2) | New |
|--------------------|-----|
| `class:^(foo)$` | `match:class = ^(foo)$` |
| `title:^(bar)$` | `match:title = ^(bar)$` |
| `class:^(foo)$, title:^(bar)$` | both `match:class` and `match:title` in same block |

Other available matchers: `match:xwayland`, `match:float`, `match:fullscreen`, `match:pin`.

### Properties and their types

Boolean flags use `= yes` / `= no`:

| Property | Description |
|----------|-------------|
| `float = yes` | Make window floating |
| `center = yes` | Center the window |
| `fullscreen = yes` | Fullscreen |
| `no_blur = yes` | Disable blur for this window |
| `no_shadow = yes` | Disable shadow |
| `no_focus = yes` | Prevent focus |
| `no_anim = yes` | Disable animations |
| `no_dim = yes` | Disable dimming |
| `opaque = yes` | Force opaque (no transparency) |
| `decorate = no` | Remove all decorations |

Value properties:

| Property | Example | Description |
|----------|---------|-------------|
| `size = W H` | `size = 2064 1350` | Set window size |
| `workspace = N silent` | `workspace = 1 silent` | Assign to workspace silently |
| `border_size = N` | `border_size = 0` | Override border size (0 = no border) |
| `rounding = N` | `rounding = 0` | Override corner rounding |
| `monitor = name` | `monitor = DP-1` | Pin to monitor |
| `move = X Y` | `move = 20 monitor_h-120` | Set position (supports monitor_w/h vars) |
| `min_size = W H` | | Minimum size |
| `max_size = W H` | | Maximum size |
| `alpha = N` | `alpha = 0.8` | Active opacity |
| `alpha_inactive = N` | | Inactive opacity |
| `animation_style = name` | | Override animation |

Note: **there is no `noborder` property** — use `border_size = 0` instead.

### Migration table (windowrulev2 → windowrule block)

| Old rule | New property |
|----------|-------------|
| `float` | `float = yes` |
| `center` | `center = yes` |
| `fullscreen` | `fullscreen = yes` |
| `noblur` | `no_blur = yes` |
| `noshadow` | `no_shadow = yes` |
| `noborder` | `border_size = 0` |
| `nofocus` | `no_focus = yes` |
| `noanim` | `no_anim = yes` |
| `size W H` | `size = W H` |
| `move X Y` | `move = X Y` |
| `workspace N silent` | `workspace = N silent` |

### How to check for config errors

```bash
hyprctl -j configerrors
```

To reload config:
```bash
hyprctl reload
```

## NVIDIA notes

This machine uses `nvidia-drm` as the primary GPU. Required env vars (already in `hyprland.conf`):

```
env = LIBVA_DRIVER_NAME,nvidia
env = NVD_BACKEND,direct
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
```

The log will always show `drm: getCurrentCRTC: No CRTC 0` errors on startup — this is normal for NVIDIA hybrid setups and can be ignored. The `Wayland backend cannot start` error on first boot is also normal (Hyprland tries nested mode first).

## Log location

```
/run/user/1000/hypr/<instance-signature>/hyprland.log
```

Full logging is disabled by default. To enable:
```
debug {
    disable_logs = false
}
```
