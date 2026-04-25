return {
    {
        "saghen/blink.cmp",
        dependencies = "rafamadriz/friendly-snippets",
        version = "v1",
        opts = {
            keymap = { preset = "default" },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },


            --completion = {
            --    menu = { border = 'padded' },
            --    documentation = { window = { border = 'padded' } }
            --},

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            signature = { enabled = true }
        },
        opts_extend = { "sources.default" },
    },
}
