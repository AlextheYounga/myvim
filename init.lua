-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.g.mapleader = " "      -- Space as leader

-- Performance: speed up Lua module loading (Neovim 0.9+)
pcall(function()
  if vim.loader and vim.loader.enable then
    vim.loader.enable()
  end
end)

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
-- Colorscheme
-----------------------------------------------------------
-- onedark variants: "dark", "darker", "cool", "deep", "warm", "warmer", "light"
local onedark_ok, onedark = pcall(require, "onedark")
if onedark_ok then
  onedark.setup({
    style = "darker",  -- Choose: dark, darker, cool, deep, warm, warmer, light
  })
  onedark.load()
else
  -- Fallback to built-in if onedark not installed
  vim.cmd("colorscheme habamax")
end

-----------------------------------------------------------
-- Better navigation
-----------------------------------------------------------
-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })

-- Clear search highlight with Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Toggle focus between nvim-tree and editor
-- NOTE: many terminals treat <Tab> as <C-i>. We map both.
local function toggle_tree_focus()
  local tree_api_ok, api = pcall(require, "nvim-tree.api")
  if not tree_api_ok then return end

  if vim.bo.filetype == "NvimTree" then
    vim.cmd("wincmd p")
  else
    api.tree.focus()
  end
end

-- Define this mapping late so plugins can't clobber it.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.keymap.set("n", "<leader><Tab>", toggle_tree_focus, {
      desc = "Toggle focus: tree <-> editor",
      silent = true,
      noremap = true,
      nowait = true,
    })
    vim.keymap.set("n", "<leader><C-i>", toggle_tree_focus, {
      desc = "Toggle focus: tree <-> editor",
      silent = true,
      noremap = true,
      nowait = true,
    })
  end,
})

-----------------------------------------------------------
-- Which-Key (keybinding cheatsheet)
-----------------------------------------------------------
vim.schedule(function()
  local wk_ok, wk = pcall(require, "which-key")
  if not wk_ok then return end

  wk.setup({
    delay = 300,  -- show popup after 300ms
    icons = {
      mappings = false,  -- disable icons (works better in SSH)
    },
  })

  -- Register key groups for better organization
  -- Don't register individual keys here; which-key v3 can override real mappings
  -- when given description-only entries. Keymaps with `desc` are auto-discovered.
  wk.add({ { "<leader>", group = "leader" } })
end)

-----------------------------------------------------------
-- Cheatsheet (searchable vim commands)
-----------------------------------------------------------
local cheat_ok, _ = pcall(require, "cheatsheet")
if cheat_ok then
  -- Press <leader>? to open searchable cheatsheet
  vim.keymap.set("n", "<leader>?", "<cmd>Cheatsheet<CR>", { desc = "Vim cheatsheet" })
end

-----------------------------------------------------------
-- Multicursors
-----------------------------------------------------------
local mc_ok, multicursors = pcall(require, "multicursors")
if mc_ok then
  multicursors.setup({})
  vim.keymap.set({ "n", "v" }, "<leader>m", "<cmd>MCstart<CR>", { desc = "Multicursor start" })
end

-----------------------------------------------------------
-- Treesitter (syntax highlighting)
-----------------------------------------------------------
vim.schedule(function()
  local ts_ok, treesitter = pcall(require, "nvim-treesitter.configs")
  if not ts_ok then return end

  treesitter.setup({
    -- Install languages automatically when opening a file
    auto_install = true,

    -- Or pre-install common languages (runs on first load)
    ensure_installed = {
      "lua", "vim", "vimdoc",      -- nvim config
      "bash", "fish",              -- shell
      "python", "javascript", "typescript", "tsx",  -- scripting
      "json", "yaml", "toml",      -- config files
      "html", "css", "php", "ruby", "vue",	-- web
      "markdown", "markdown_inline",
      "go", "rust", "c", "zig",         -- systems
      "dockerfile", "terraform",  -- devops
    },

    highlight = {
      enable = true,  -- enable syntax highlighting
    },

    indent = {
      enable = true,  -- better auto-indentation
    },
  })
end)

-----------------------------------------------------------
-- File Explorer (nvim-tree)
-----------------------------------------------------------
vim.schedule(function()
  local tree_ok, nvimtree = pcall(require, "nvim-tree")
  if not tree_ok then return end

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
end)

-----------------------------------------------------------
-- OSC52 clipboard: any yank → local clipboard
-----------------------------------------------------------
-- Works over SSH, tmux, etc. - copies to YOUR local machine
local osc52_ok, osc52 = pcall(require, "osc52")
if osc52_ok then
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
