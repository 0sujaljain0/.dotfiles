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

            -- Mason-lspconfig now handles the bridge automatically
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "gopls" },
                -- This is the modern replacement for setup_handlers
                automatic_enable = true,
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- 1. GLOBAL CONFIG: Apply to ALL servers
            -- This replaces the need for a setup_handlers loop
            vim.lsp.config("*", {
                capabilities = capabilities,
                settings = {
                    -- Enable hints for most modern servers
                    hint = { enable = true },
                },
            })

            -- 2. SERVER SPECIFIC CONFIGS
            -- Neovim 0.12 merges these into the global config above
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
                -- IMPORTANT: Remove 'helm' from the default filetypes
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
                        yamlls = {
                            enabled = true, -- helm_ls will now "proxy" yamlls correctly
                            path = "yaml-language-server",
                        }
                    }
                }
            })

            vim.lsp.config("lua_ls", {
                settings = { Lua = { diagnostics = { globals = { "vim" } } } }
            })

            -- 3. GLOBAL UI Styling
            vim.diagnostic.config({
                virtual_text = { prefix = "●", spacing = 4 },
                float = { border = "rounded", source = "always" },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- 4. Global LspAttach
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    -- Essential Keybinds
                    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                    map("n", "gr", vim.lsp.buf.references, "Goto References")
                    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Actions")
                    map("n", "[d", vim.diagnostic.open_float, "Show Line Error")

                    -- GLOBAL INLAY HINT ENGINE
                    if client and client.server_capabilities.inlayHintProvider then
                        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                        map("n", "<leader>th", function()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
                                { bufnr = event.buf }
                            )
                        end, "Toggle Inlay Hints")
                    end
                end,
            })

            -- Ensure hints are visible
            vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#888888", italic = true })
        end,
    },
    {
        "saghen/blink.cmp",
        version = "*",
        opts = {
            keymap = { preset = "default" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
    },
}
