# My Neovim Setup

Portable Neovim configuration that works on any Linux server or macOS machine.

## Quick Install

```bash
git clone https://github.com/AlextheYounga/myvim.git
cd ~/myvim
./setup-nvim.sh
```

Then start a new shell or run:
```bash
export PATH="${HOME}/.local/bin:${PATH}"
nvim
```

## Platform Support

| Platform | Method |
|----------|--------|
| Linux x86_64 | Downloads official binary |
| Linux aarch64 | Builds from source |
| macOS (Intel/Apple Silicon) | Downloads official binary |

## Plugins

| Plugin | Purpose |
|--------|---------|
| [onedark.nvim](https://github.com/navarasu/onedark.nvim) | One Dark colorscheme (VS Code style) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer sidebar |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File icons |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints popup |
| [cheatsheet.nvim](https://github.com/sudormrfbin/cheatsheet.nvim) | Searchable Vim commands |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utilities (telescope dependency) |
| [nvim-osc52](https://github.com/ojroques/nvim-osc52) | Clipboard over SSH |

## Keybindings

### Custom Keybindings

| Key | Action |
|-----|--------|
| `Space + e` | Toggle file explorer |
| `Space + E` | Reveal current file in explorer |
| `Space + ?` | Open searchable Vim cheatsheet |
| `Space` + wait | Show all leader keybindings (which-key) |
| `Ctrl + a` | Select all |
| `Ctrl + d` | Scroll down (centered) |
| `Ctrl + u` | Scroll up (centered) |
| `Esc` | Clear search highlight |

### File Explorer (nvim-tree)

| Key | Action |
|-----|--------|
| `a` | Create new file/folder |
| `d` | Delete |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |
| `q` | Close explorer |
| `g?` | Show all nvim-tree keybindings |

### Useful Vim Commands

| Command | Action |
|---------|--------|
| `:%y` | Yank (copy) entire file |
| `:%y+` | Yank entire file to system clipboard |
| `ggVG` | Select entire file |
| `:TSInstall <lang>` | Install treesitter parser for a language |
| `:TSInstallInfo` | Show installed/available parsers |

## Settings

- **Leader key**: `Space`
- **Theme**: One Dark (darker variant)
- **Indentation**: 2 spaces, auto-expand tabs
- **Line numbers**: Absolute (not relative)
- **Mouse**: Enabled
- **Search**: Case-insensitive (smart case)
- **Clipboard**: System clipboard + OSC52 over SSH

## Treesitter Languages (Pre-installed)

Lua, Vim, Bash, Fish, Python, JavaScript, TypeScript, TSX, JSON, YAML, TOML, HTML, CSS, PHP, Ruby, Vue, Markdown, Go, Rust, C, Zig, Dockerfile, Terraform

Additional languages auto-install when you open a file.

## File Structure

```
~/.local/nvim/           # Neovim installation
~/.local/bin/nvim        # Symlink to nvim binary
~/.config/nvim/init.lua  # Configuration
~/.local/share/nvim/     # Plugins and data
```

## Uninstall

```bash
rm -rf ~/.local/nvim ~/.local/bin/nvim ~/.config/nvim ~/.local/share/nvim
```

## Requirements

- `git` - for cloning plugins
- `curl` or `wget` - for downloading Neovim
- `gcc` or `clang` - for treesitter (installed automatically)
- `cmake`, `ninja` - only for aarch64 Linux (builds from source)
