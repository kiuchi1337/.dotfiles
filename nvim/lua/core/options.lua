local opt = vim.opt

opt.shortmess:append("I")
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.termguicolors = true
opt.list = true
opt.listchars = {
  tab = ">-",
  trail = "~",
  space = "·",
  eol = "$",
}
opt.spell = true
opt.spelllang = { "en", "de" }

vim.cmd.colorscheme("zaibatsu")
