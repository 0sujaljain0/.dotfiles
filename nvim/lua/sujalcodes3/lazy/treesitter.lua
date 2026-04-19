return {
    -- Sticky context (shows function/class you're inside at top of screen)
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufReadPost",
        opts = {
            max_lines = 3,
            trim_scope = "outer",
            mode = "cursor",
        },
    },

    -- Parser management + highlighting for languages not bundled with Neovim
    -- Neovim 0.12 only bundles: c, lua, markdown, vim, vimdoc, query
    -- Go, TypeScript, Rust, etc. need this plugin
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "go", "javascript", "typescript", "tsx",
                "html", "css", "json", "yaml", "toml",
                "rust", "python", "bash",
                "markdown", "markdown_inline",
            })

            -- Enable highlighting for all filetypes with available parsers
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },
}
