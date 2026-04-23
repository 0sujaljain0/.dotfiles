return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "gopls" },
                automatic_enable = true,
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- Global config for all servers
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- Server-specific configs (only what differs from defaults)
            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                    },
                },
            })

            vim.lsp.config("yamlls", {
                filetypes = { "yaml", "yaml.docker-compose", "yaml.gitignore" },
                settings = {
                    yaml = {
                        schemas = {
                            kubernetes = "templates/**",
                            ["http://json.schemastore.org/chart"] = "Chart.yaml",
                        },
                    },
                },
            })

            vim.lsp.config("helm_ls", {
                settings = {
                    ["helm-ls"] = {
                        yamlls = { enabled = true, path = "yaml-language-server" },
                    },
                },
            })

            vim.lsp.config("lua_ls", {
                settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })

            -- Diagnostic UI
            vim.diagnostic.config({
                virtual_text = { prefix = "●", spacing = 4 },
                float = { border = "rounded", source = "always" },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- Custom keymaps (in addition to built-in: K=hover, grn=rename, grr=references, gra=code_action, grt=type_def)
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                    map("n", "[d", vim.diagnostic.open_float, "Show Line Diagnostic")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
                end,
            })
        end,
    },
}
