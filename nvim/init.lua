--------------------------------------------------
-- Plugins (Neovim 0.12+)
--------------------------------------------------

vim.pack.add({
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/rebelot/kanagawa.nvim",
})

--------------------------------------------------
-- Options
--------------------------------------------------

local opt = vim.opt

-- UI
opt.termguicolors = true
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Split behavior
opt.splitright = true
opt.splitbelow = true

-- Persistent undo
opt.undofile = true

-- Startup message
opt.shortmess:append("I")

-- Show whitespace
opt.list = true
opt.listchars = {
    tab = "→ ",
    space = "·",
    trail = "•",
    nbsp = "␣",
}

--opt.listchars = {
--    tab = ">-",
--    space = "·",
--    trail = "~",
--    nbsp = "_",
--}

-- Spell checking
opt.spell = true
opt.spelllang = { "en", "de" }

-- Disable mouse
opt.mouse = ""

--------------------------------------------------
-- Colorscheme
--------------------------------------------------

vim.cmd.colorscheme("kanagawa-wave")
--vim.cmd.colorscheme("kanagawa-dragon")
--vim.cmd.colorscheme("habamax")

--------------------------------------------------
-- mini.nvim
--------------------------------------------------

require("mini.ai").setup()
require("mini.comment").setup()
require("mini.files").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.statusline").setup()

--------------------------------------------------
-- Keymaps
--------------------------------------------------

vim.keymap.set("n", "-", function()
    MiniFiles.open()
end, { desc = "Open MiniFiles" })
