-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.g.mapleader = " "      -- Space as leader

local opt = vim.opt

opt.mouse = "a"            -- enable mouse in terminal
opt.number = true          -- show line numbers
opt.relativenumber = false -- disable relative numbers (no "backwards" effect)
opt.wrap = false           -- don't wrap long lines

-----------------------------------------------------------
-- Select all (Ctrl+A)
-----------------------------------------------------------
-- ggVG = go to top, select to bottom
vim.keymap.set({ "n", "x" }, "<C-a>", "ggVG", { desc = "Select all" })

-- If you configure your terminal to send Ctrl+A when you press Command+A,
-- this becomes "Command+A selects entire file" inside Neovim.

-----------------------------------------------------------
-- OSC52 clipboard: any yank → local clipboard
-----------------------------------------------------------
-- Requires: ojroques/nvim-osc52 (the script you ran installs it)
local ok, osc52 = pcall(require, "osc52")
if ok then
  osc52.setup({
    max_length = 0,  -- no length limit
    silent = true,
    trim = false,
  })

  -- Whenever you yank (y, yy, y$, visual y, etc.), send it to local clipboard.
  -- This includes `yy`, which is what you asked for.
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      if vim.v.event.operator == "y" then
        -- Use the register that was yanked from; default is unnamed ("")
        local reg = vim.v.event.regname
        if reg == "" then reg = '"' end
        osc52.copy_register(reg)
      end
    end,
  })
end

