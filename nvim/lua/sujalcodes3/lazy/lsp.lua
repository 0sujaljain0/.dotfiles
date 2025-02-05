return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
			{
				"williamboman/mason.nvim",
				dependencies = {
					"williamboman/mason-lspconfig.nvim",
				},
				config = function()
					local capabilities = require("blink.cmp").get_lsp_capabilities()

					local on_attach = function(_, _)
						require("lspconfig.ui.windows").default_options = {
							border = "single",
						}
						vim.keymap.set("n", "gd", function()
							vim.lsp.buf.definition()
						end, {})
						vim.keymap.set("n", "K", function()
							vim.lsp.buf.hover()
						end, {})
						vim.keymap.set("n", "<leader>vws", function()
							vim.lsp.buf.workspace_symbol()
						end, {})
						vim.keymap.set("n", "<leader>vd", function()
							vim.diagnostic.open_float()
						end, {})
						vim.keymap.set("n", "[d", function()
							vim.diagnostic.goto_next()
						end, {})
						vim.keymap.set("n", "]d", function()
							vim.diagnostic.goto_prev()
						end, {})
						vim.keymap.set("n", "<leader>ca", function()
							vim.lsp.buf.code_action()
						end, {})
						vim.keymap.set("n", "<leader>vrr", function()
							vim.lsp.buf.references()
						end, {})
						vim.keymap.set("n", "<leader>vrn", function()
							vim.lsp.buf.rename()
						end, {})
						vim.keymap.set("i", "<C-a>", function()
							vim.lsp.buf.signature_help()
						end, {})
					end

					vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
						vim.lsp.diagnostic.on_publish_diagnostics,
						{
							-- delay update diagnostics
							update_in_insert = true,
						},
						{
							border = "single",
						}
					)
					vim.lsp.handlers["textDocument/signatureHelp"] =
						vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
					vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

					require("mason").setup({})
					require("mason-lspconfig").setup({
						ensure_installed = {
							"tailwindcss",
							"lua_ls",
							"templ",
							"rust_analyzer",
							"gopls",
							"html",
							"clangd",
						},
						handlers = {
							function(server_name)
								if server_name == "lua_ls" then
									require("lspconfig")[server_name].setup({
										settings = {
											Lua = {
												diagnostics = {
													globals = { "vim" },
												},
											},
										},
										on_attach = on_attach,
										capabilities = capabilities,
									})
								elseif server_name == "tailwindcss" then
									require("lspconfig")[server_name].setup({
										on_attach = on_attach,
										capabilities = capabilities,
										filetypes = { "templ", "astro", "javascript", "typescript", "react", "html" },
										settings = {
											tailwindCSS = {
												includeLanguages = {
													templ = "html",
												},
											},
										},
									})
								elseif server_name == "html" then
									require("lspconfig")[server_name].setup({
										on_attach = on_attach,
										capabilities = capabilities,
										filetypes = { "templ", "astro", "javascript", "typescript", "react", "html" },
									})
								else
									require("lspconfig")[server_name].setup({
										on_attach = on_attach,
										capabilities = capabilities,
									})
								end
							end,
						},
					})
				end,
			},
		},
	},
}
