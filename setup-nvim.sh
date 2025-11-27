#!/usr/bin/env bash
set -e

# =============================================================
# Single-file Neovim setup for any Linux server
# Usage: curl -fsSL <url>/setup-nvim.sh | bash
#    or: bash setup-nvim.sh
# =============================================================

NVIM_VERSION="v0.10.3"  # Pin to a known stable version
NVIM_DIR="${HOME}/.local/nvim"
NVIM_BIN="${HOME}/.local/bin/nvim"
CONFIG_DIR="${HOME}/.config/nvim"
PLUGIN_DIR="${HOME}/.local/share/nvim/site/pack/plugins/start"

# Detect architecture and OS
get_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux)
      case "$arch" in
        x86_64)  echo "linux-x86_64" ;;
        aarch64|arm64) echo "linux-aarch64" ;;
        *)       echo "unsupported"; return 1 ;;
      esac
      ;;
    Darwin)
      case "$arch" in
        x86_64)  echo "macos-x86_64" ;;
        arm64)   echo "macos-arm64" ;;
        *)       echo "unsupported"; return 1 ;;
      esac
      ;;
    *)
      echo "unsupported"; return 1 ;;
  esac
}

# Install Neovim build dependencies
install_build_deps() {
  echo "📦 Installing build dependencies..."
  
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y ninja-build cmake gcc make unzip gettext curl
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm base-devel cmake unzip ninja curl
  elif command -v apk &>/dev/null; then
    sudo apk add build-base cmake coreutils curl unzip gettext-tiny-dev ninja
  else
    echo "❌ No supported package manager found for installing build deps"
    exit 1
  fi
}

# Build Neovim from source (for aarch64 Linux)
build_neovim_from_source() {
  echo "🔨 Building Neovim ${NVIM_VERSION} from source..."
  echo "   This may take a few minutes..."
  
  install_build_deps
  
  local build_dir="${HOME}/.local/src/neovim"
  rm -rf "$build_dir"
  mkdir -p "$build_dir"
  
  # Download source
  local source_url="https://github.com/neovim/neovim/archive/refs/tags/${NVIM_VERSION}.tar.gz"
  echo "   Downloading source from: ${source_url}"
  
  if command -v curl &>/dev/null; then
    curl -fsSL "$source_url" | tar xz -C "$build_dir" --strip-components=1
  elif command -v wget &>/dev/null; then
    wget -qO- "$source_url" | tar xz -C "$build_dir" --strip-components=1
  fi
  
  cd "$build_dir"
  
  # Build with CMAKE_INSTALL_PREFIX to install to ~/.local/nvim
  make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$NVIM_DIR"
  make install
  
  # Symlink to ~/.local/bin
  mkdir -p "${HOME}/.local/bin"
  ln -sf "${NVIM_DIR}/bin/nvim" "$NVIM_BIN"
  
  # Cleanup source
  rm -rf "$build_dir"
  
  echo "✅ Neovim built and installed to ${NVIM_BIN}"
}

# Install Neovim from GitHub releases (no sudo required)
install_neovim() {
  local platform
  platform=$(get_platform)
  
  if [ "$platform" = "unsupported" ]; then
    echo "❌ Unsupported platform: $(uname -s) $(uname -m)"
    exit 1
  fi

  # aarch64 Linux has no official binary - build from source
  if [ "$platform" = "linux-aarch64" ]; then
    echo "⚠️  No official Neovim binary for Linux aarch64"
    echo "   Building from source..."
    echo ""
    build_neovim_from_source
    return
  fi

  local tarball="nvim-${platform}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${tarball}"

  echo "📦 Downloading Neovim ${NVIM_VERSION} for ${platform}..."
  echo "   URL: ${url}"
  
  mkdir -p "${HOME}/.local/bin"
  rm -rf "$NVIM_DIR"
  mkdir -p "$NVIM_DIR"

  if command -v curl &>/dev/null; then
    curl -fsSL "$url" | tar xz -C "$NVIM_DIR" --strip-components=1
  elif command -v wget &>/dev/null; then
    wget -qO- "$url" | tar xz -C "$NVIM_DIR" --strip-components=1
  else
    echo "❌ Neither curl nor wget found. Please install one."
    exit 1
  fi

  # Symlink to ~/.local/bin
  ln -sf "${NVIM_DIR}/bin/nvim" "$NVIM_BIN"
  echo "✅ Neovim installed to ${NVIM_BIN}"
}

# Install plugins
install_plugins() {
  echo "📦 Installing plugins..."
  mkdir -p "$PLUGIN_DIR"

  if ! command -v git &>/dev/null; then
    echo "⚠️  git not found, skipping plugin install"
    return
  fi

  # nvim-osc52 - clipboard over SSH
  if [ ! -d "${PLUGIN_DIR}/nvim-osc52" ]; then
    git clone --depth 1 https://github.com/ojroques/nvim-osc52.git "${PLUGIN_DIR}/nvim-osc52"
    echo "✅ Installed nvim-osc52"
  else
    echo "✅ nvim-osc52 already installed"
  fi

  # nvim-tree - file explorer sidebar
  if [ ! -d "${PLUGIN_DIR}/nvim-tree.lua" ]; then
    git clone --depth 1 https://github.com/nvim-tree/nvim-tree.lua.git "${PLUGIN_DIR}/nvim-tree.lua"
    echo "✅ Installed nvim-tree"
  else
    echo "✅ nvim-tree already installed"
  fi

  # nvim-web-devicons - file icons (optional but nice)
  if [ ! -d "${PLUGIN_DIR}/nvim-web-devicons" ]; then
    git clone --depth 1 https://github.com/nvim-tree/nvim-web-devicons.git "${PLUGIN_DIR}/nvim-web-devicons"
    echo "✅ Installed nvim-web-devicons"
  else
    echo "✅ nvim-web-devicons already installed"
  fi

  # which-key - keybinding cheatsheet popup
  if [ ! -d "${PLUGIN_DIR}/which-key.nvim" ]; then
    git clone --depth 1 https://github.com/folke/which-key.nvim.git "${PLUGIN_DIR}/which-key.nvim"
    echo "✅ Installed which-key"
  else
    echo "✅ which-key already installed"
  fi

  # plenary - required dependency for telescope
  if [ ! -d "${PLUGIN_DIR}/plenary.nvim" ]; then
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git "${PLUGIN_DIR}/plenary.nvim"
    echo "✅ Installed plenary"
  else
    echo "✅ plenary already installed"
  fi

  # telescope - fuzzy finder (required for cheatsheet)
  if [ ! -d "${PLUGIN_DIR}/telescope.nvim" ]; then
    git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim.git "${PLUGIN_DIR}/telescope.nvim"
    echo "✅ Installed telescope"
  else
    echo "✅ telescope already installed"
  fi

  # cheatsheet - searchable vim commands cheatsheet
  if [ ! -d "${PLUGIN_DIR}/cheatsheet.nvim" ]; then
    git clone --depth 1 https://github.com/sudormrfbin/cheatsheet.nvim.git "${PLUGIN_DIR}/cheatsheet.nvim"
    echo "✅ Installed cheatsheet"
  else
    echo "✅ cheatsheet already installed"
  fi

  # nvim-treesitter - syntax highlighting and code parsing
  if [ ! -d "${PLUGIN_DIR}/nvim-treesitter" ]; then
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter.git "${PLUGIN_DIR}/nvim-treesitter"
    echo "✅ Installed nvim-treesitter"
  else
    echo "✅ nvim-treesitter already installed"
  fi

  # onedark - colorscheme with great treesitter support
  if [ ! -d "${PLUGIN_DIR}/onedark.nvim" ]; then
    git clone --depth 1 https://github.com/navarasu/onedark.nvim.git "${PLUGIN_DIR}/onedark.nvim"
    echo "✅ Installed onedark colorscheme"
  else
    echo "✅ onedark already installed"
  fi
}

# Copy init.lua configuration
install_config() {
  echo "📝 Installing Neovim config..."
  mkdir -p "$CONFIG_DIR"

  # Get the directory where this script is located
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  if [ ! -f "${SCRIPT_DIR}/init.lua" ]; then
    echo "⚠️  init.lua not found in ${SCRIPT_DIR}"
    echo "   Please manually copy your init.lua to ${CONFIG_DIR}/init.lua"
    return
  fi

  # Check if config already exists and is identical
  if [ -f "${CONFIG_DIR}/init.lua" ]; then
    if cmp -s "${SCRIPT_DIR}/init.lua" "${CONFIG_DIR}/init.lua"; then
      echo "✅ Config already up to date at ${CONFIG_DIR}/init.lua"
      return
    else
      # Backup existing config before overwriting
      local backup="${CONFIG_DIR}/init.lua.backup.$(date +%Y%m%d%H%M%S)"
      cp "${CONFIG_DIR}/init.lua" "$backup"
      echo "📋 Backed up existing config to ${backup}"
    fi
  fi

  cp "${SCRIPT_DIR}/init.lua" "${CONFIG_DIR}/init.lua"
  echo "✅ Config copied to ${CONFIG_DIR}/init.lua"
}

# Update PATH in shell config
update_path() {
  local shell_rc=""
  
  if [ -n "$BASH_VERSION" ] || [ -f "${HOME}/.bashrc" ]; then
    shell_rc="${HOME}/.bashrc"
  fi
  if [ -n "$ZSH_VERSION" ] || [ -f "${HOME}/.zshrc" ]; then
    shell_rc="${HOME}/.zshrc"
  fi

  local path_line='export PATH="${HOME}/.local/bin:${PATH}"'
  
  if [ -n "$shell_rc" ] && ! grep -qF '.local/bin' "$shell_rc" 2>/dev/null; then
    echo "" >> "$shell_rc"
    echo "# Added by nvim setup" >> "$shell_rc"
    echo "$path_line" >> "$shell_rc"
    echo "✅ Added ~/.local/bin to PATH in ${shell_rc}"
  fi
}

# Main
main() {
  echo "🚀 Setting up Neovim..."
  echo ""

  # Check if nvim already exists and is working
  if [ -x "$NVIM_BIN" ] && "$NVIM_BIN" --version &>/dev/null; then
    echo "✅ Neovim already installed at ${NVIM_BIN}"
    "$NVIM_BIN" --version | head -1
  else
    install_neovim
  fi

  install_plugins
  install_config
  update_path

  echo ""
  echo "=========================================="
  echo "✅ Setup complete!"
  echo ""
  echo "To use now:  export PATH=\"\${HOME}/.local/bin:\${PATH}\""
  echo "Then run:    nvim"
  echo ""
  echo "Or start a new shell session."
  echo "=========================================="
}

main "$@"
