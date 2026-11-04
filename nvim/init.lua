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

-- Leader Key (Space)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- Disable mouse
opt.mouse = ""

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

----------------------------------------------------
-- Spellchecking Logic & Keymaps
----------------------------------------------------

opt.spell = true
opt.spelllang = { "en" }

-- Cycle order: EN -> DE -> DE+EN
local spell_languages = {
    { "en" },
    { "de" },
    { "de", "en" },
}
local current_lang_index = 1

-- Function to get the status string for the statusline
local function get_spell_status()
    if not vim.wo.spell then
        return "SPELL: OFF"
    end
    local langs = table.concat(vim.opt.spelllang:get(), ","):upper()
    return "SPELL: " .. langs
end

-- 1. Toggle Spellcheck (On / Off)
vim.keymap.set("n", "<leader>st", function()
    vim.wo.spell = not vim.wo.spell
    print("Spellcheck: " .. (vim.wo.spell and "ACTIVATED (" .. table.concat(vim.opt.spelllang:get(), ",") .. ")" or "DEACTIVATED"))
    vim.cmd("redrawstatus")
end, { desc = "Toggle Spellcheck (On/Off)" })

-- 2. Cyclic language switch (EN -> DE -> DE+EN)
vim.keymap.set("n", "<leader>sl", function()
    current_lang_index = (current_lang_index % #spell_languages) + 1
    vim.opt.spelllang = spell_languages[current_lang_index]
    
    -- Enable spellcheck automatically if it was disabled when switching
    if not vim.wo.spell then
        vim.wo.spell = true
    end

    local langs_str = table.concat(vim.opt.spelllang:get(), ","):upper()
    print("Spellcheck language changed to: " .. langs_str)
    vim.cmd("redrawstatus")
end, { desc = "Switch Spellcheck Language (EN -> DE -> DE+EN)" })

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
require("mini.completion").setup()
require("mini.files").setup()
require("mini.pairs").setup()
require("mini.statusline").setup()
require("mini.surround").setup()

-- mini.statusline with custom spellcheck status section
local statusline = require("mini.statusline")
statusline.setup({
    content = {
        active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local git           = statusline.section_git({ trunc_width = 75 })
            local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
            local filename      = statusline.section_filename({ trunc_width = 140 })
            local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
            local location      = statusline.section_location({ trunc_width = 75 })
            
            -- Custom spellcheck section
            local spell_info    = get_spell_status()

            return statusline.combine_groups({
                { hl = mode_hl,                  strings = { mode } },
                { hl = "MiniStatuslineDevinfo",  strings = { git, diagnostics } },
                "%<", -- Truncate-Point
                { hl = "MiniStatuslineFilename", strings = { filename } },
                "%=", -- Right Alignment Marker
                { hl = "MiniStatuslineModeOther", strings = { spell_info } },
                { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
                { hl = mode_hl,                  strings = { location } },
            })
        end,
    },
})

--------------------------------------------------
-- Keymaps
--------------------------------------------------

vim.keymap.set("n", "-", function()
    MiniFiles.open()
end, { desc = "Open MiniFiles" })

-- Tab completion keymaps in Insert Mode
local imap_expr = function(lhs, rhs)
    vim.keymap.set("i", lhs, rhs, { expr = true, replace_keycodes = false })
end

-- Tab selects next item if menu is open, otherwise inserts literal Tab
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
-- Shift-Tab selects previous item
imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])