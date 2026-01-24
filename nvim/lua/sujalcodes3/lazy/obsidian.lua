return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        legacy_commands = false,
        workspaces = {
            {
                name = "gettinshitdun.blog",
                path = "~/main/obsidian_vaults/blog/content/",
            },
            {
                name = "personal",
                path = "~/main/obsidian_vaults/obsidian/",
            },
        },
    },
    config = function(_, opts)
        -- Set conceallevel for obsidian's UI features (requires 1 or 2)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
                vim.opt_local.conceallevel = 2
            end,
        })
        require("obsidian").setup(opts)
    end,
}
