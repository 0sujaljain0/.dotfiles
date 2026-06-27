return {
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				signs = true, -- show icons in the signs column
				sign_priority = 8, -- sign priority
				keywords = {
					TODO = { icon = "󰄱 ", color = "info", alt = { "todo" } },
					FIXME = { icon = "󰒡 ", color = "error", alt = { "fixme", "fix" } },
					HACK = { icon = "󰒉 ", color = "warning" },
					WARN = { icon = "󰀪 ", color = "warning", alt = { "warning", "warn" } },
					PERF = { icon = "󰅒 ", alt = { "perf", "performance" } },
					THINKABOUT = { icon = "󰌵 ", color = "thinkabout", alt = { "consider", "think about" } },
					NOTE = { icon = "󰎔 ", color = "hint", alt = { "note" } },
					TEST = { icon = "󰙨 ", color = "test", alt = { "test", "testing" } },
				},
				gui_style = {
					fg = "NONE",
					bg = "BOLD",
				},
				merge_keywords = true,
				highlight = {
					multiline = true,
					multiline_pattern = "^.",
					multiline_context = 10,
					before = "",
					keyword = "wide",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\s*:]],
					comments_only = true, -- uses treesitter to match keywords in comments only
					max_line_len = 400,
					exclude = {},
				},
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					thinkabout = { "Constant", "#A855F7" },
					default = { "Identifier", "#7C3AED" },
					test = { "Identifier", "#FF00FF" },
				},
			})
			
			-- Initialize custom TODO finder plugin
			local todo_finder = require("sujalcodes3.todo_finder")
			
			-- Setup with custom configuration (extendible)
			todo_finder.setup({
				keywords = {
					TODO = { icon = "󰄱 ", color = "InfoMsg" },
					FIXME = { icon = "󰒡 ", color = "ErrorMsg" },
					HACK = { icon = "󰒉 ", color = "WarningMsg" },
					WARN = { icon = "󰀪 ", color = "WarningMsg" },
					PERF = { icon = "󰅒 ", color = "WarningMsg" },
					NOTE = { icon = "󰎔 ", color = "InfoMsg" },
					TEST = { icon = "󰙨 ", color = "InfoMsg" },
					-- Add more keywords here as needed
				},
				exclude_patterns = {
					"node_modules/**",
					".git/**",
					"**/target/**",
					"**/dist/**",
					"**/build/**",
				},
				exclude_filetypes = {},
			})
			
			-- Keybinding to open TODO finder (uses treesitter to find comments only)
			vim.keymap.set("n", "<leader>tt", function()
				todo_finder.show_todos()
			end, { desc = "Find TODO comments (Treesitter)" })
		end,
	},
}

