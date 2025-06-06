_G.brace_command_mode = false
vim.g.mapleader = " "

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<leader>pv", "<cmd>lua MiniFiles.open()<CR>")

vim.keymap.set("n", "<leader>sa", "ggVG")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")


vim.keymap.set("n", "<C-y>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>st", "I~<C-c>A~<C-c>")


vim.keymap.set("n", "<cmd> TmuxNavigateLeft<CR>", "<C-h>")
vim.keymap.set("n", "<cmd> TmuxNavigateRight<CR>", "<C-l>")
vim.keymap.set("n", "<cmd> TmuxNavigateUp<CR>", "<C-k>")
vim.keymap.set("n", "<cmd> TmuxNavigateDown<CR>", "<C-j>")

vim.cmd[[command! -nargs=1 Gc lua require'sujalcodes3.custom'.gccompile(<f-args>)]]

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>");
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>");

vim.keymap.set("n", "<leader>rcs", "<cmd>lua ColorMyPencils()<CR>");

vim.keymap.set("n", "<leader>bp", function ()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 10)
    local job_id = vim.bo.channel
    vim.fn.chansend(job_id, { "make build\r\n" })
end)
vim.keymap.set("n", "<leader>rp", function ()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 10)
    local job_id = vim.bo.channel
    vim.fn.chansend(job_id, { "make run\r\n" })
end)
vim.keymap.set("n", "<leader>wp", function ()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 10)
    local job_id = vim.bo.channel
    vim.fn.chansend(job_id, { "make watch\r\n" })
end)


vim.keymap.set("n", "<leader>pc", function()
    local fname = vim.fn.expand("%")
    local fnameLen = string.len(fname)
    local movement = string.rep("\\<Left>", fnameLen + 1)
    _G.brace_command_mode = true
    vim.cmd("call feedkeys(':!" .. " " .. fname .. "', 'n')")
    vim.cmd("call feedkeys(\"" .. movement .. "\", 'n')")
end, { noremap = true, silent = true })
