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
opt.shortmess:append("Ic")

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

-- Loads defaults unless stated otherwise
-- mini.completion and mini.statusline are commented out because of specific settings below 
require("mini.ai").setup()
require("mini.comment").setup()
--require("mini.completion").setup()
require("mini.files").setup()
require("mini.pairs").setup()
require("mini.pick").setup()
--require("mini.statusline").setup()
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

----------------------------------------------------
-- mini.completion Configuration (Strict LSP-only)
----------------------------------------------------

require("mini.completion").setup({
    -- Restrict sources strictly to LSP and omni, disabling noisy buffer word matching
    sources = {
        { name = 'lsp',  freq = 1 },
        { name = 'omni', freq = 2 },
        { name = 'keyword', freq = 3 },
    },
    window = {
        info = { border = "solid" },
        signature = { border = "solid" },
    },
    fallback_action = function()
        return ""
    end,
})

----------------------------------------------------
-- Python LSP & Ruff Configuration (Pixi-Aware & Robust)
----------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
        -- Safe project root directory detection
        local buf_name = vim.api.nvim_buf_get_name(args.buf)
        local search_path = buf_name ~= "" and buf_name or nil
        local found = vim.fs.find({ "pixi.toml", "pyproject.toml", "setup.py", ".git" }, { upward = true, path = search_path })
        local root_dir = found[1] and vim.fs.dirname(found[1]) or vim.fn.getcwd()

        -- Define local Pixi binary and python paths
        local pixi_bin = root_dir .. "/.pixi/envs/default/bin"
        local pyright_path = pixi_bin .. "/pyright-langserver"
        local ruff_path = pixi_bin .. "/ruff"
        local python_path = pixi_bin .. "/python"

        -- Fallback to system executables if local Pixi env doesn't exist
        local pyright_cmd = vim.fn.executable(pyright_path) == 1 and pyright_path or "pyright-langserver"
        local ruff_cmd = vim.fn.executable(ruff_path) == 1 and ruff_path or "ruff"
        local python_cmd = vim.fn.executable(python_path) == 1 and python_path or "python"

        -- Check active clients to prevent duplicate starts
        local active_clients = vim.lsp.get_clients({ bufnr = args.buf })
        local function has_client(name)
            for _, client in ipairs(active_clients) do
                if client.name == name then return true end
            end
            return false
        end

        -- 1. Start Pyright
        if not has_client("pyright") and vim.fn.executable(pyright_cmd) == 1 then
            vim.lsp.start({
                name = "pyright",
                cmd = { pyright_cmd, "--stdio" },
                root_dir = root_dir,
                settings = {
                    python = {
                        pythonPath = python_cmd,
                    },
                },
            }, { bufnr = args.buf })
        end

        -- 2. Start Ruff
        if not has_client("ruff") and vim.fn.executable(ruff_cmd) == 1 then
            vim.lsp.start({
                name = "ruff",
                cmd = { ruff_cmd, "server" },
                root_dir = root_dir,
            }, { bufnr = args.buf })
        end
    end,
})

----------------------------------------------------
-- Custom LspInfo Command (for Native LSP)
----------------------------------------------------

vim.api.nvim_create_user_command("LspInfo", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        print("No active LSP clients attached to current buffer.")
        return
    end

    print("--- Active LSP Clients ---")
    for _, client in ipairs(clients) do
        print("Name: " .. client.name .. " (ID: " .. client.id .. ")")
        print("Root Dir: " .. (client.config.root_dir or "N/A"))
        if client.config.settings and client.config.settings.python then
            print("Python Path: " .. (client.config.settings.python.pythonPath or "N/A"))
        end
        print("--------------------------")
    end
end, { desc = "Show active LSP client info for current buffer" })

--------------------------------------------------
-- Keymaps
--------------------------------------------------

-- Open file explorer
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

-- mini.pick Keymaps
vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Pick files" })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Live grep (search in files)" })
vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Pick buffers" })

-- LSP Keymaps
vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, { desc = "LSP: Go to definition" })
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = "LSP: Hover documentation" })
vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { desc = "LSP: Rename symbol" })
vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = "LSP: Code action" })
vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP: Format file" })