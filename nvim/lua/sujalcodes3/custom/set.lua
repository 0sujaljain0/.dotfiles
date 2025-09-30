-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- set the cursor to blockx/
--vim.opt.guicursor = "i:hor40-Cursor/lCursor, i:ver30"
--vim.opt.guicursor = ""

vim.opt.listchars = {eol = '↵', tab = '  '}
vim.opt.list = true

vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false

-- tab width
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

vim.g.mapleader = " "
vim.g.base16_shell_path = "base16-builder/output/shell/"

vim.opt.autoread = true
--vim.opt.cursorline = true

vim.opt.textwidth = 120

-- for obsidian
vim.opt.conceallevel = 1

vim.filetype.add({ extension = { templ = "templ" } })
