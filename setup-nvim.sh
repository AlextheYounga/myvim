#!/usr/bin/env bash
set -e

# =============================================================
# Single-file Neovim setup for any Linux server
# Usage: curl -fsSL <url>/setup-nvim.sh | bash
#    or: bash setup-nvim.sh
# =============================================================

NVIM_VERSION="v0.10.2"  # Pin to a known stable version
NVIM_DIR="${HOME}/.local/nvim"
NVIM_BIN="${HOME}/.local/bin/nvim"
CONFIG_DIR="${HOME}/.config/nvim"
PLUGIN_DIR="${HOME}/.local/share/nvim/site/pack/plugins/start"

# Detect architecture
get_arch() {
  case "$(uname -m)" in
    x86_64)  echo "x86_64" ;;
    aarch64) echo "aarch64" ;;
    arm64)   echo "aarch64" ;;
    *)       echo "unsupported"; return 1 ;;
  esac
}

# Install Neovim from GitHub releases (no sudo required)
install_neovim() {
  local arch
  arch=$(get_arch)
  
  if [ "$arch" = "unsupported" ]; then
    echo "❌ Unsupported architecture: $(uname -m)"
    exit 1
  fi

  local tarball="nvim-linux-${arch}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${tarball}"

  echo "📦 Downloading Neovim ${NVIM_VERSION} for ${arch}..."
  
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

# Install nvim-osc52 plugin
install_plugins() {
  echo "📦 Installing plugins..."
  mkdir -p "$PLUGIN_DIR"

  if [ ! -d "${PLUGIN_DIR}/nvim-osc52" ]; then
    if command -v git &>/dev/null; then
      git clone --depth 1 https://github.com/ojroques/nvim-osc52.git "${PLUGIN_DIR}/nvim-osc52"
      echo "✅ Installed nvim-osc52"
    else
      echo "⚠️  git not found, skipping plugin install"
    fi
  else
    echo "✅ nvim-osc52 already installed"
  fi
}

# Copy init.lua configuration
install_config() {
  echo "📝 Installing Neovim config..."
  mkdir -p "$CONFIG_DIR"

  # Get the directory where this script is located
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  if [ -f "${SCRIPT_DIR}/init.lua" ]; then
    cp "${SCRIPT_DIR}/init.lua" "${CONFIG_DIR}/init.lua"
    echo "✅ Config copied to ${CONFIG_DIR}/init.lua"
  else
    echo "⚠️  init.lua not found in ${SCRIPT_DIR}"
    echo "   Please manually copy your init.lua to ${CONFIG_DIR}/init.lua"
  fi
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
