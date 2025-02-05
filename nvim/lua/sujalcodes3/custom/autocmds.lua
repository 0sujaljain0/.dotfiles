vim.api.nvim_create_autocmd("TermOpen", {
	desc = "build command projects",
	group = vim.api.nvim_create_augroup("project-specific-build", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" }, callback = vim.lsp.buf.format })
