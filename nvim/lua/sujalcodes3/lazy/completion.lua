return {
    {
        "saghen/blink.cmp",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "yaocccc/blink-cmp-cmdlinehistory",
        },
        version = "v1",
        opts = {
            keymap = { preset = "default" },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },

            cmdline = {
                enabled = true,
                keymap = { preset = 'cmdline' },
                sources = function()
                    local type = vim.fn.getcmdtype()
                    -- Use the buffer text to suggest completions when searching with / or ?
                    if type == '/' or type == '?' then return { 'buffer' } end
                    -- Use Neovim's native command line suggestions when typing :
                    if type == ':' then return { "cmdline_history", 'cmdline' } end
                    return {}
                end,
                completion = {
                    menu = {
                        auto_show = true, -- Automatically popup the menu as you type
                        draw = {
                            columns = { { "label", "label_description", gap = 1 } },
                        },
                    },
                    ghost_text = {
                        enabled = true, -- Shows a faded preview of the top suggestion right in the command line
                    }
                }
            },


                completion = {
                    menu = { border = 'none' },
                    documentation = { window = { border = 'padded' } }
                },

                sources = {
                    default = { "lsp", "path", "snippets", "buffer" },
                    providers = {
                        cmdline_history = {
                            name = "history",
                            module = "cmdlinehistory",
                            score_offset = 999,
                        }
                    }
                },
                signature = { enabled = true }
            },
            opts_extend = { "sources.default" },
        },
    }
