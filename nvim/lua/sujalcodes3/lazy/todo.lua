return {
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup({
                signs = true,
                sign_priority = 8,
                keywords = {
                    TODO = { icon = "󰄱 ", color = "info", alt = { "todo" } },
                    FIXME = { icon = "󰒡 ", color = "error", alt = { "fixme", "fix" } },
                    HACK = { icon = "󰒉 ", color = "warning" },
                    WARN = { icon = "󰀪 ", color = "warning", alt = { "warning", "warn" } },
                    PERF = { icon = "󰅒 ", alt = { "perf", "performance" } },
                    THINKABOUT = { icon = "󰌵 ", color = "thinkabout", alt = { "consider", "think about" } },
                    NOTE = { icon = "󰎔 ", color = "hint", alt = { "note" } },
                    TEST = { icon = "󰙨 ", color = "test", alt = { "test", "testing" } },
                    CASE = { icon = "󰠋 ", color = "case", alt = { "case", "cases" } },
                    -- Define START and END as their own markers
                    START = { icon = "▶ ", color = "start_block", alt = { "start" } },
                    END = { icon = "⏹ ", color = "end_block", alt = { "end" } },
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
                    pattern = [[.*<(KEYWORDS)\s*:]], -- Requires a colon after the keyword
                    comments_only = true,
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
                    case = { "Type", "#06B6D4" }, -- Cyan color for cases

                    -- Custom colors for your code boundaries
                    start_block = { "String", "#10B981" }, -- Greenish for start
                    end_block = { "String", "#EF4444" },   -- Reddish for end
                },
            })

            local todo_finder = require("sujalcodes3.todo_finder")

            todo_finder.setup({
                keywords = {
                    TODO = { icon = "󰄱 ", color = "InfoMsg" },
                    FIXME = { icon = "󰒡 ", color = "ErrorMsg" },
                    HACK = { icon = "󰒉 ", color = "WarningMsg" },
                    WARN = { icon = "󰀪 ", color = "WarningMsg" },
                    PERF = { icon = "󰅒 ", color = "WarningMsg" },
                    NOTE = { icon = "󰎔 ", color = "InfoMsg" },
                    TEST = { icon = "󰙨 ", color = "InfoMsg" },
                    CASE = { icon = "󰠋 ", color = "Type" },

                    -- Add them to your custom finder
                    START = { icon = "▶ ", color = "String" },
                    END = { icon = "⏹ ", color = "ErrorMsg" },
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

            vim.keymap.set("n", "<leader>tt", function()
                todo_finder.show_todos()
            end, { desc = "Find TODO comments (Treesitter)" })
        end,
    },
}
