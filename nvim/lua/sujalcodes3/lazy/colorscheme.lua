function ColorMyPencils(color)
    color = color or "koda"
    vim.opt.termguicolors = true
    vim.cmd.colorscheme(color)
end

return {
    {
        "oskarnurm/koda.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("koda").setup({
                transparent = true, -- enable for transparent backgrounds

                -- Set the variants to use when auto-switching based on vim.o.background
                -- Valid values: 'dark', 'light', 'moss', 'glade'
                theme = {
                    dark = "dark",
                    light = "light",
                },

                -- Automatically enable highlights only for plugins installed by your plugin manager
                -- Currently only supports `lazy.nvim`, `mini.deps` and `vim.pack`
                auto = true,  -- disable to load ALL available plugin highlights

                cache = true, -- caches the theme for better performance

                -- Style to be applied to different syntax groups
                -- Common use case would be to set either `italic = true` or `bold = true` for a desired group
                -- See `:help nvim_set_hl` for more valid values
                styles = {
                    functions = { bold = false },
                    keywords  = { bold = true },
                    keyword_return = { bold = true },
                    comments  = {},
                    strings   = {},
                    constants = {}, -- includes numbers, booleans
                },

                -- Override colors for the active variant
                -- Available keys (e.g., 'func') can be found in lua/koda/palette/
                colors = {
                    -- func = "#4078F2",
                    keyword = "#FAD33B",
                    keyword_return = "#FAD33B",
                },

                -- You can modify or extend highlight groups using the `on_highlights` configuration option
                -- Any changes made take effect when highlights are applied
                on_highlights = function(hl, c)
                    -- hl.LineNr = { fg = c.info } -- change a specific highlight to use a different palette color
                    -- hl.Comment = { fg = c.emphasis, italic = true } -- modify a syntax group (add bold, italic, etc)
                    -- hl.RainbowDelimiterRed = { fg = "#fb2b2b" } -- add a custom highlight group for another plugin
                end,
            })
        end,
    },
    {
        "metalelf0/black-metal-theme-neovim",
        lazy = false,
        priority = 1000,
        config = function()
            require("black-metal").load(require("black-metal").setup({
                -----MAIN OPTIONS-----
                --
                -- Can be one of: bathory | burzum | dark-funeral | darkthrone | emperor | gorgoroth | immortal | impaled-nazarene | khold | marduk | mayhem | nile | taake | thyrfing | venom | windir
                theme = "bathory",
                -- Can be one of: 'light' | 'dark', or set via vim.o.background
                variant = "dark",
                -- Use an alternate, lighter bg
                alt_bg = true,
                -- If true, docstrings will be highlighted like strings, otherwise they will be
                -- highlighted like comments. Note, behavior is dependent on the language server.
                colored_docstrings = true,
                -- If true, highlights the {sign,fold} column the same as cursorline
                cursorline_gutter = true,
                -- If true, highlights the gutter darker than the bg
                dark_gutter = false,
                -- if true favor treesitter highlights over semantic highlights
                favor_treesitter_hl = false,
                -- Don't set background of floating windows. Recommended for when using floating
                -- windows with borders.
                plain_float = false,
                -- Show the end-of-buffer character
                show_eob = true,
                -- If true, enable the vim terminal colors
                term_colors = true,
                -- Keymap (in normal mode) to toggle between light and dark variants.
                toggle_variant_key = nil,
                -- Don't set background
                transparent = true,

                -----DIAGNOSTICS and CODE STYLE-----
                --
                diagnostics = {
                    darker = true, -- Darker colors for diagnostic
                    undercurl = true, -- Use undercurl for diagnostics
                    background = true, -- Use background color for virtual text
                },
                -- The following table accepts values the same as the `gui` option for normal
                -- highlights. For example, `bold`, `italic`, `underline`, `none`.
                code_style = {
                    comments = "italic",
                    conditionals = "none",
                    functions = "none",
                    keywords = "none",
                    headings = "bold", -- Markdown headings
                    operators = "none",
                    keyword_return = "none",
                    strings = "none",
                    variables = "none",
                },

                -----PLUGINS-----
                --
                -- The following options allow for more control over some plugin appearances.
                plugin = {
                    lualine = {
                        -- Bold lualine_a sections
                        bold = true,
                        -- Don't set section/component backgrounds. Recommended to not set
                        -- section/component separators.
                        plain = false,
                    },
                    cmp = { -- works for nvim.cmp and blink.nvim
                        -- Don't highlight lsp-kind items. Only the current selection will be highlighted.
                        plain = false,
                        -- Reverse lsp-kind items' highlights in blink/cmp menu.
                        reverse = false,
                    },
                },

                -- CUSTOM HIGHLIGHTS --
                --
                -- Override default colors
                colors = {},
                -- Override highlight groups
                highlights = {},
            }),
            -- Convenience function that simply calls `:colorscheme <theme>` with the theme
            -- specified in your config.
            require("black-metal").load())
        end,
    },
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
        "EdenEast/nightfox.nvim",
        config = function ()

            -- Default options
            require('nightfox').setup({
                options = {
                    -- Compiled file's destination location
                    compile_path = vim.fn.stdpath("cache") .. "/nightfox",
                    compile_file_suffix = "_compiled", -- Compiled file suffix
                    transparent = true,     -- Disable setting background
                    terminal_colors = true,  -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
                    dim_inactive = false,    -- Non focused panes set to alternative background
                    module_default = true,   -- Default enable value for modules
                    colorblind = {
                        enable = false,        -- Enable colorblind support
                        simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
                        severity = {
                            protan = 0,          -- Severity [0,1] for protan (red)
                            deutan = 0,          -- Severity [0,1] for deutan (green)
                            tritan = 0,          -- Severity [0,1] for tritan (blue)
                        },
                    },
                    styles = {               -- Style to be applied to different syntax groups
                        comments = "NONE",     -- Value is any valid attr-list value `:help attr-list`
                        conditionals = "NONE",
                        constants = "NONE",
                        functions = "NONE",
                        keywords = "NONE",
                        numbers = "NONE",
                        operators = "NONE",
                        strings = "NONE",
                        types = "NONE",
                        variables = "NONE",
                    },
                    inverse = {             -- Inverse highlight for different types
                        match_paren = false,
                        visual = false,
                        search = false,
                    },
                    modules = {             -- List of various plugins and additional options
                        -- ...
                    },
                },
                palettes = {},
                specs = {},
                groups = {},
            })

            -- setup must be called before loading
            vim.cmd("colorscheme nightfox")

        end
    },
    {
        "rose-pine/neovim",
        config = function ()
            require("rose-pine").setup({
                variant = "main", -- auto, main, main, or dawn
                dark_variant = "main", -- main, main, or dawn
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
            "rebelot/kanagawa.nvim",
            config = function()
                require('kanagawa').setup({
                    compile = false,             -- enable compiling the colorscheme
                    undercurl = true,            -- enable undercurls
                    commentStyle = { italic = true },
                    functionStyle = {},
                    keywordStyle = { bold = true, italic = false},
                    statementStyle = { bold = true },
                    typeStyle = {},
                    transparent = true,         -- do not set background color
                    dimInactive = true,         -- dim inactive window `:h hl-NormalNC`
                    terminalColors = true,       -- define vim.g.terminal_color_{0,17}
                    colors = {                   -- add/modify theme and palette colors
                        palette = {},
                        theme = { wave = {}, lotus = {}, dragon = {}, all = {
                            ui = {
                                bg_gutter = "none"
                            }
                        } },
                    },
                    overrides = function(colors)
                        local theme = colors.theme
                        return {
                            NormalFloat = { bg = "none" },
                            FloatBorder = { bg = "none" },
                            FloatTitle = { bg = "none" },

                            -- Save an hlgroup with dark background and dimmed foreground
                            -- so that you can use it where your still want darker windows.
                            -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
                            NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

                            -- Popular plugins that open floats will link to NormalFloat by default;
                            -- set their background accordingly if you wish to keep them dark and borderless
                            LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                            MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                        }
                    end,
                    theme = "wave",              -- Load "wave" theme
                    background = {               -- map the value of 'background' option to a theme
                        dark = "wave",           -- try "wave" !
                        light = "lotus"
                    },
                })
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
