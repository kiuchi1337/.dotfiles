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

-- Leader Key (Space)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
opt.shortmess:append("Ic")

-- Disable mouse
opt.mouse = ""

-- Show whitespace
opt.list = true
opt.listchars = { tab = "→ ", space = "·", trail = "•", nbsp = "␣" }
-- opt.listchars = { tab = ">-", space = "·", trail = "~", nbsp = "_" }

-- Theme
vim.cmd.colorscheme("kanagawa-wave")
-- vim.cmd.colorscheme("kanagawa-dragon")
-- vim.cmd.colorscheme("habamax")

--------------------------------------------------
-- Spellcheck
--------------------------------------------------

opt.spell = true
opt.spelllang = { "en" }

local map = vim.keymap.set
local spell_languages = { { "en" }, { "de" }, { "de", "en" } }
local spell_index = 1

local function spell_status()
    return vim.wo.spell
        and "SPELL: " .. table.concat(opt.spelllang:get(), ","):upper()
        or "SPELL: OFF"
end

map("n", "<leader>st", function()
    vim.wo.spell = not vim.wo.spell
    local state = vim.wo.spell and "ACTIVATED (" .. table.concat(opt.spelllang:get(), ",") .. ")" or "DEACTIVATED"
    print("Spellcheck: " .. state)
    vim.cmd.redrawstatus()
end, { desc = "Toggle Spellcheck (On/Off)" })

map("n", "<leader>sl", function()
    spell_index = spell_index % #spell_languages + 1
    opt.spelllang = spell_languages[spell_index]
    vim.wo.spell = true
    print("Spellcheck language changed to: " .. table.concat(opt.spelllang:get(), ","):upper())
    vim.cmd.redrawstatus()
end, { desc = "Switch Spellcheck Language (EN -> DE -> DE+EN)" })

for _, module in ipairs({ "ai", "comment", "files", "git", "pairs", "pick", "surround" }) do
    require("mini." .. module).setup()
end

--------------------------------------------------
-- MINI Setup
--------------------------------------------------

require("mini.diff").setup({
    view = { style = "sign", signs = { add = "▒", change = "▒", delete = "▒" } },
})

local statusline = require("mini.statusline")
statusline.setup({
    content = {
        active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            return statusline.combine_groups({
                { hl = mode_hl, strings = { mode } },
                {
                    hl = "MiniStatuslineDevinfo",
                    strings = {
                        statusline.section_git({ trunc_width = 75 }),
                        statusline.section_diagnostics({ trunc_width = 75 }),
                    },
                },
                "%<",
                { hl = "MiniStatuslineFilename", strings = { statusline.section_filename({ trunc_width = 140 }) } },
                "%=",
                { hl = "MiniStatuslineModeOther", strings = { spell_status() } },
                { hl = "MiniStatuslineFileinfo", strings = { statusline.section_fileinfo({ trunc_width = 120 }) } },
                { hl = mode_hl, strings = { statusline.section_location({ trunc_width = 75 }) } },
            })
        end,
    },
})

require("mini.completion").setup({
    sources = {
        { name = "lsp", freq = 1 },
        { name = "omni", freq = 2 },
        { name = "keyword", freq = 3 },
    },
    window = { info = { border = "solid" }, signature = { border = "solid" } },
    fallback_action = function() return "" end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
        local name = vim.api.nvim_buf_get_name(args.buf)
        local found = vim.fs.find(
            { "pixi.toml", "pyproject.toml", "setup.py", ".git" },
            { upward = true, path = name ~= "" and name or nil }
        )
        local root = found[1] and vim.fs.dirname(found[1]) or vim.fn.getcwd()
        local bin = root .. "/.pixi/envs/default/bin"
        local executables = {
            pyright = { bin .. "/pyright-langserver", "pyright-langserver" },
            ruff = { bin .. "/ruff", "ruff" },
            python = { bin .. "/python", "python" },
        }

        for key, paths in pairs(executables) do
            if vim.fn.executable(paths[1]) == 1 then
                executables[key] = paths[1]
            else
                executables[key] = paths[2]
            end
        end

        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        local function active(name)
            for _, client in ipairs(clients) do
                if client.name == name then return true end
            end
        end

        if not active("pyright") and vim.fn.executable(executables.pyright) == 1 then
            vim.lsp.start({
                name = "pyright",
                cmd = { executables.pyright, "--stdio" },
                root_dir = root,
                settings = { python = { pythonPath = executables.python } },
            }, { bufnr = args.buf })
        end
        if not active("ruff") and vim.fn.executable(executables.ruff) == 1 then
            vim.lsp.start({
                name = "ruff",
                cmd = { executables.ruff, "server" },
                root_dir = root,
            }, { bufnr = args.buf })
        end
    end,
})

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
        local python = client.config.settings and client.config.settings.python
        if python then print("Python Path: " .. (python.pythonPath or "N/A")) end
        print("--------------------------")
    end
end, { desc = "Show active LSP client info for current buffer" })

map("n", "-", function() MiniFiles.open() end, { desc = "Open MiniFiles" })
map("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true, replace_keycodes = false })
map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true, replace_keycodes = false })

local pick = {
    ["<leader>ff"] = { MiniPick.builtin.files, "Pick files" },
    ["<leader>fg"] = { MiniPick.builtin.grep_live, "Live grep (search in files)" },
    ["<leader>fb"] = { MiniPick.builtin.buffers, "Pick buffers" },
}
for key, value in pairs(pick) do map("n", key, value[1], { desc = value[2] }) end

for key, value in pairs({
    gd = { vim.lsp.buf.definition, "LSP: Go to definition" },
    K = { vim.lsp.buf.hover, "LSP: Hover documentation" },
    ["<leader>rn"] = { vim.lsp.buf.rename, "LSP: Rename symbol" },
    ["<leader>ca"] = { vim.lsp.buf.code_action, "LSP: Code action" },
    ["<leader>f"] = { function() vim.lsp.buf.format({ async = true }) end, "LSP: Format file" },
}) do
    map("n", key, value[1], { desc = value[2] })
end

map("n", "]h", function() MiniDiff.goto_hunk("next") end, { desc = "Next hunk" })
map("n", "[h", function() MiniDiff.goto_hunk("prev") end, { desc = "Previous hunk" })
for _, mode in ipairs({ "n", "x" }) do
    map(mode, "<leader>hs", 'v:lua.MiniDiff.operator("apply")', { expr = mode == "n", desc = "Stage hunk" })
    map(mode, "<leader>hr", 'v:lua.MiniDiff.operator("reset")', { expr = mode == "n", desc = "Reset hunk" })
end
map("n", "<leader>gc", function() MiniGit.show_at_cursor() end, { desc = "Git details at cursor" })

map("n", "<leader>fr", function()
    local registers = { '"', "-", ":", ".", "%", "#", "/", "=", "?", "_" }
    for i = 0, 9 do registers[#registers + 1] = tostring(i) end
    for i = 0, 25 do registers[#registers + 1] = string.char(string.byte("a") + i) end

    local items = {}
    for _, reg in ipairs(registers) do
        local value = vim.fn.getreg(reg)
        if value and value ~= "" then
            local display = value:gsub("\n", "\\n")
            if #display > 50 then display = display:sub(1, 47) .. "..." end
            items[#items + 1] = { text = string.format(":%s: %s", reg, display), value = value }
        end
    end
    MiniPick.start({
        source = {
            name = "Registers",
            items = items,
            choose = function(item)
                if item then
                    vim.schedule(function() vim.api.nvim_put(vim.split(item.value, "\n"), "c", true, true) end)
                end
            end,
        },
    })
end, { desc = "Pick registers" })