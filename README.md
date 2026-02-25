# Clipboard History — Noctalia Shell Plugin

A bar plugin for [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) that maintains a persistent clipboard history with full add, paste, and delete support.

## Features

- 📋 **Auto-capture** — monitors your Wayland clipboard in real time via `wl-paste --watch`
- 🔁 **De-duplication** — moving a repeated entry to the top rather than creating a duplicate
- ✏️ **Manual add** — type or paste any text directly into the panel
- 🖱️ **One-click copy** — click any entry to copy it back to your clipboard
- 🗑️ **Delete individual entries** or **clear all** with a confirmation dialog
- 💾 **Persistent** — history survives shell restarts (stored via `pluginApi.saveSettings`)
- ⚙️ **Configurable** — max history size, preview length, and monitoring toggle

## Requirements

| Dependency | Package (CachyOS/Arch) |
|------------|------------------------|
| `wl-paste` | `wl-clipboard` |
| `wl-copy`  | `wl-clipboard` |
| Noctalia Shell | ≥ 3.6.0 |

Install the clipboard tool if you don't have it:

```bash
sudo pacman -S wl-clipboard
```

## Installation

### Option A — From your plugins directory (local development)

```bash
# Clone into Noctalia's plugin folder
git clone https://github.com/mcwiseman97/Clipboard-History \
    ~/.config/noctalia/plugins/clipboard-history

# Restart Noctalia
killall qs && qs -p ~/.config/noctalia/noctalia-shell
```

Then:
1. Open **Noctalia Settings** → **Plugins** tab
2. Find **Clipboard History** → click **Enable**
3. Go to **Settings** → **Bar** tab → add the widget to Left/Center/Right

### Option B — Via a custom plugin registry

Add your fork as a plugin source in Noctalia Settings → Plugins → Sources.

## Usage

| Action | How |
|--------|-----|
| Open panel | Click the clipboard icon in the bar |
| Copy an entry | Click the row, or hover and click the copy icon |
| Delete an entry | Hover a row → click the trash icon |
| Add entry manually | Click **+** in the panel header |
| Clear all history | Click the global trash icon → confirm |

## File Structure

```
clipboard-history/
├── manifest.json              # Plugin metadata
├── Main.qml                   # Background service (wl-paste watcher, state)
├── BarWidget.qml              # Bar icon + count badge
├── Panel.qml                  # Dropdown history panel
├── ClipboardEntryDelegate.qml # Single row component
├── Settings.qml               # Settings UI
└── README.md
```

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| Monitor Clipboard | `true` | Auto-capture clipboard changes |
| Maximum History Size | `50` | Max number of entries to keep |
| Preview Length | `60` | Characters shown per entry in the list |

## Development & Hot Reload

Enable hot reload in Noctalia Settings → Plugins → enable "Hot Reload" for this plugin. Any save to a `.qml` file will reload the plugin instantly.

```bash
# View live logs
journalctl --user -u noctalia -f
# or
qs logs
```

## License

MIT
