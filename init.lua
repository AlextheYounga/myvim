-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.g.mapleader = " "      -- Space as leader

local opt = vim.opt

opt.mouse = "a"            -- enable mouse in terminal
opt.number = true          -- show line numbers
opt.relativenumber = false -- disable relative numbers
opt.wrap = false           -- don't wrap long lines
opt.termguicolors = true   -- enable 24-bit colors
opt.signcolumn = "yes"     -- always show sign column
opt.updatetime = 250       -- faster completion
opt.timeoutlen = 300       -- faster key sequence completion
opt.clipboard = "unnamedplus" -- use system clipboard when available

-- Search settings
opt.ignorecase = true      -- ignore case in search
opt.smartcase = true       -- unless uppercase is used
opt.hlsearch = true        -- highlight search results

-- Indentation
opt.expandtab = true       -- use spaces instead of tabs
opt.shiftwidth = 2         -- shift 2 spaces
opt.tabstop = 2            -- tab = 2 spaces
opt.smartindent = true     -- auto-indent new lines

-----------------------------------------------------------
-- Select all (Ctrl+A)
-----------------------------------------------------------
vim.keymap.set({ "n", "x" }, "<C-a>", "ggVG", { desc = "Select all" })

-----------------------------------------------------------
-- Better navigation
-----------------------------------------------------------
-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })

-- Clear search highlight with Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-----------------------------------------------------------
-- File Explorer (nvim-tree)
-----------------------------------------------------------
local tree_ok, nvimtree = pcall(require, "nvim-tree")
if tree_ok then
  -- Disable netrw (vim's built-in explorer) to avoid conflicts
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  nvimtree.setup({
    view = {
      width = 30,
      side = "left",
    },
    renderer = {
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
    filters = {
      dotfiles = false,  -- show hidden files
    },
    git = {
      enable = true,
      ignore = false,
    },
  })

  -- Keymaps
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
  vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", { desc = "Find current file in explorer" })
end

-----------------------------------------------------------
-- OSC52 clipboard: any yank → local clipboard
-----------------------------------------------------------
-- Works over SSH, tmux, etc. - copies to YOUR local machine
local ok, osc52 = pcall(require, "osc52")
if ok then
  osc52.setup({
    max_length = 0,  -- no length limit
    silent = true,
    trim = false,
  })

  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      if vim.v.event.operator == "y" then
        local reg = vim.v.event.regname
        if reg == "" then reg = '"' end
        osc52.copy_register(reg)
      end
    end,
  })
else
  -- Fallback: highlight yanked text (built into Neovim 0.10+)
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      vim.highlight.on_yank({ timeout = 200 })
    end,
  })
end

