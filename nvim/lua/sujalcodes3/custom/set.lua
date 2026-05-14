vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldtext = ""
vim.opt.foldlevel = 3
vim.opt.foldnestmax = 4
vim.opt.foldlevelstart = 1
vim.opt.wrap = false

-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true
--vim.opt.guicursor = ""
--vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver40,r-cr:hor20,o:hor50"
--vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#FFFFFF', bg = '#FF0000' })

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

vim.filetype.add({ extension = { templ = "templ" } })
