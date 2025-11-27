#!/usr/bin/env bash
set -e

# Install neovim and git (safe even if already installed)
sudo apt update
sudo apt install -y neovim git

# Install nvim-osc52 plugin using the native package path
PLUGIN_DIR="${HOME}/.local/share/nvim/site/pack/plugins/start"
mkdir -p "$PLUGIN_DIR"

if [ ! -d "${PLUGIN_DIR}/nvim-osc52" ]; then
  git clone https://github.com/ojroques/nvim-osc52.git "${PLUGIN_DIR}/nvim-osc52"
  echo "Installed nvim-osc52 in ${PLUGIN_DIR}/nvim-osc52"
else
  echo "nvim-osc52 already present in ${PLUGIN_DIR}/nvim-osc52"
fi

echo
echo "Done."
echo "Now put your init.lua in: ~/.config/nvim/init.lua"
echo "Then start Neovim with: nvim"

