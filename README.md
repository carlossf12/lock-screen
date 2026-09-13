# Lock Screen

Version 1.4.0

A customizable Omarchy lock screen with secure authentication, multi-monitor
support, and a visual wallpaper selector.

## Features

- Password authentication and fingerprint compatibility
- Multi-monitor support
- Four bundled wallpaper presets
- Current Omarchy wallpaper mode
- Custom absolute-path wallpaper mode
- Safe fallback wallpaper
- Visual wallpaper selector with Apply and Cancel
- Optional user-configured keyboard shortcut

## Requirements

Tested with Omarchy 4.0.3-1. The plugin requires an Omarchy installation with
shell plugin support. Quickshell and the plugin system are provided by Omarchy;
they are not separate installation steps for a normal Omarchy system.

## Installation

Install the Git-managed plugin with:

```bash
omarchy plugin add https://github.com/carlossf12/lock-screen.git
```

Omarchy clones it into
`~/.config/omarchy/plugins/carlossf12.lock-screen`, validates the plugin, and
rescans shell plugins automatically. A manual `rescanPlugins` is not part of
the normal installation flow.

## First Use / Activation

Before enabling the custom lock, confirm that `omarchy.lock` is available for
rollback:

```bash
omarchy plugin list
```

Enable the plugin:

```bash
omarchy plugin enable carlossf12.lock-screen
```

The manifest declares `clonedFrom: omarchy.lock`. Enabling this clone makes
Omarchy substitute it for the official lock and disable `omarchy.lock` through
the normal clone mechanism. A shell restart is not normally required.

Check the resulting state:

```bash
omarchy plugin list
```

The list should show `carlossf12.lock-screen` enabled and `omarchy.lock`
disabled. Before depending on the custom lock, perform one normal lock and
confirm that the correct password unlocks the session.

## Usage

Lock the session normally with:

```text
Super + Ctrl + L
```

Open or close the wallpaper selector with:

```bash
omarchy-shell shell toggle carlossf12.lock-screen '{}'
```

## Wallpaper Selector

The selector provides three modes:

- **Fixed:** Misty Torii Shrine, Moonlit Mountain, Celestial Torii, or
  Synthwave Torii Sunset.
- **Current:** uses the current Omarchy wallpaper on the next lock.
- **Custom:** uses an absolute image path supplied by the user.

Selecting a mode or preset changes only the current draft. `Apply` validates
and persists it; `Cancel` closes the panel without changing the saved
configuration.

## Configurable Wallpaper

The selector normally manages the runtime configuration, so manual editing is
not required. The file is stored at:

```text
~/.config/omarchy/carlossf12.lock-screen.json
```

Example:

```json
{
  "backgroundMode": "fixed",
  "backgroundPath": "",
  "fixedPreset": "misty-torii-shrine"
}
```

- `backgroundMode`: `fixed`, `current`, or `custom`.
- `backgroundPath`: absolute image path used by Custom mode.
- `fixedPreset`: bundled preset remembered even while Current or Custom mode is
  active.

## Keyboard Shortcut

`Super + Ctrl + Alt + L` is the recommended optional shortcut for the
wallpaper selector. Add it to `~/.config/hypr/bindings.lua`:

```lua
o.bind(
  "SUPER + CTRL + ALT + L",
  "Lock Screen settings",
  "omarchy-shell shell toggle carlossf12.lock-screen '{}'"
)
```

The plugin does not create or overwrite bindings. The user owns this entry and
may choose any free key combination. Inspect configured shortcuts with:

```bash
omarchy menu keybindings --print
```

## Wallpaper Troubleshooting

- A missing, empty, or invalid `fixedPreset` falls back to Misty Torii Shrine.
- Missing, empty, or invalid JSON falls back safely to Fixed mode and Misty.
- An invalid or unreadable Custom path falls back to Misty.
- Custom paths must be absolute.
- Browse/FileDialog is not currently available; enter the absolute path.
- If an update or hot reload leaves the panel stale or incomplete, recover with
  `omarchy restart shell`. This is not a normal installation or activation
  step.

## Updating

Update the Git-managed plugin with:

```bash
omarchy plugin update carlossf12.lock-screen
```

The Omarchy update command validates the updated plugin and rescans plugins
automatically. Afterwards, run `omarchy plugin list`, open the selector, and
perform one normal lock/unlock test.

If an Omarchy update changes the official lock implementation, confirm that
this plugin still loads and unlocks correctly before depending on it. Use
`omarchy restart shell` only if the normal hot reload remains incomplete.

## Rollback

Use rollback if the custom plugin does not load, locking fails, an update is
incompatible, or you want to return immediately to the official lock:

```bash
omarchy plugin disable carlossf12.lock-screen
omarchy plugin enable omarchy.lock
omarchy restart shell
omarchy plugin list
```

The final list should show `carlossf12.lock-screen` disabled and `omarchy.lock`
enabled.

## Remove

Restore the official lock before removing the plugin:

```bash
omarchy plugin disable carlossf12.lock-screen
omarchy plugin enable omarchy.lock
omarchy plugin list
omarchy plugin remove carlossf12.lock-screen
```

Confirm that `omarchy.lock` is enabled before running the remove command.
Removal rescans shell plugins automatically. It does not remove the user's
runtime configuration at `~/.config/omarchy/carlossf12.lock-screen.json`.

## License

This project is available under the [MIT License](LICENSE). The four bundled
wallpaper images were generated specifically for this project.
