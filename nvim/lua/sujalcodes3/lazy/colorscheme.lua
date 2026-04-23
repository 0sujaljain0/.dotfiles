function ColorMyPencils(color)
    color = color or "onedark"
    vim.opt.termguicolors = true
    vim.cmd.colorscheme(color)
end

return {
    -- Using Lazy
    {
        "navarasu/onedark.nvim",
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('onedark').setup  {
                -- Main options --
                style = 'warmer', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
                transparent = true,  -- Show/hide background
                term_colors = true, -- Change terminal color as per the selected theme style
                ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
                cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

                -- toggle theme style ---
                toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
                toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between

                -- Change code style ---
                -- Options are italic, bold, underline, none
                -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
                code_style = {
                    comments = 'italic',
                    keywords = 'bold',
                    functions = 'none',
                    strings = 'none',
                    variables = 'none'
                },

                -- Lualine options --
                lualine = {
                    transparent = true, -- lualine center bar transparency
                },

                -- Custom Highlights --
                colors = {}, -- Override default colors
                highlights = {}, -- Override highlight groups

                -- Plugins Config --
                diagnostics = {
                    darker = true, -- darker colors for diagnostic
                    undercurl = true,   -- use undercurl instead of underline for diagnostics
                    background = true,    -- use background color for virtual text
                },
            }
            require('onedark').load()
        end
    },
    {
        "rose-pine/neovim",
        config = function ()
            require("rose-pine").setup({
                variant = "auto", -- auto, main, moon, or dawn
                dark_variant = "main", -- main, moon, or dawn
                dim_inactive_windows = false,
                extend_background_behind_borders = true,

                enable = {
                    terminal = true,
                    legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
                    migrations = true, -- Handle deprecated options automatically
                },

                styles = {
                    bold = true,
                    italic = false,
                    transparency = true,
                },

                groups = {
                    border = "muted",
                    link = "iris",
                    panel = "surface",

                    error = "love",
                    hint = "iris",
                    info = "foam",
                    note = "pine",
                    todo = "rose",
                    warn = "gold",

                    git_add = "foam",
                    git_change = "rose",
                    git_delete = "love",
                    git_dirty = "rose",
                    git_ignore = "muted",
                    git_merge = "iris",
                    git_rename = "pine",
                    git_stage = "iris",
                    git_text = "rose",
                    git_untracked = "subtle",

                    h1 = "iris",
                    h2 = "foam",
                    h3 = "rose",
                    h4 = "gold",
                    h5 = "pine",
                    h6 = "foam",
                },

                palette = {
                    -- Override the builtin palette per variant
                    -- moon = {
                        --     base = '#18191a',
                        --     overlay = '#363738',
                        -- },
                    },

                    -- NOTE: Highlight groups are extended (merged) by default. Disable this
                    -- per group via `inherit = false`
                    highlight_groups = {
                        -- Comment = { fg = "foam" },
                        -- StatusLine = { fg = "love", bg = "love", blend = 15 },
                        -- VertSplit = { fg = "muted", bg = "muted" },
                        -- Visual = { fg = "base", bg = "text", inherit = false },
                    },

                    before_highlight = function(group, highlight, palette)
                        -- Disable all undercurls
                        -- if highlight.undercurl then
                        --     highlight.undercurl = false
                        -- end
                        --
                        -- Change palette colour
                        -- if highlight.fg == palette.pine then
                        --     highlight.fg = palette.foam
                        -- end
                    end,
                })
            end
    },
    {
        "vague2k/vague.nvim",
        config = function ()
            require("vague").setup({
                transparent = true,
                style = {
                    boolean = "bold",
                    number = "none",
                    float = "none",
                    error = "bold",
                    comments = "italic",
                    conditionals = "bold",
                    functions = "none",
                    headings = "bold",
                    operators = "none",
                    strings = "none",
                    variables = "none",

                    -- keywords
                    keywords = "bold",
                    keyword_return = "bold",
                    keywords_loop = "bold",
                    keywords_label = "bold",
                    keywords_exception = "none",

                    -- builtin
                    builtin_constants = "bold",
                    builtin_functions = "none",
                    builtin_types = "bold",
                    builtin_variables = "none",
                }
            })
        end
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup {
                transparent = true,
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                    keywords = { bold = true },
                },
                on_highlights = function(hl, c)
                    -- 1. Floating Windows (LSP Hover, Signature Help, etc.)
                    hl.NormalFloat = { bg = "none" }
                    hl.FloatBorder = { bg = "none" }
                    hl.FloatTitle  = { bg = "none" }
                    -- 2. LSP Virtual Text (Hints, Errors, etc. that appear on the line)
                    hl.DiagnosticVirtualTextError = { bg = "none", fg = c.error }
                    hl.DiagnosticVirtualTextWarn  = { bg = "none", fg = c.warning }
                    hl.DiagnosticVirtualTextInfo  = { bg = "none", fg = c.info }
                    hl.DiagnosticVirtualTextHint  = { bg = "none", fg = c.hint }
                    -- 3. Diagnostic Floating Windows (from vim.diagnostic.open_float)
                    hl.DiagnosticNormalFloat = { bg = "none" }
                end,

            }
        end
    },
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000 ,
        config = function ()
            require("gruvbox").setup({
                terminal_colors = true, -- add neovim terminal colors
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                inverse = true, -- invert background for search, diffs, statuslines and errors
                contrast = "soft", -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = true,
            })
        end
    }
}
