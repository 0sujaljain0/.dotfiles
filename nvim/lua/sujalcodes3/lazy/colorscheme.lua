function ColorMyPencils(color)
    color = color or "solarized-osaka"
    vim.opt.termguicolors = true
    vim.cmd.colorscheme(color)
end

return {
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("cyberdream").setup({
                -- Set light or dark variant
                variant = "default", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`

                -- Enable transparent background
                transparent = true,

                -- Reduce the overall saturation of colours for a more muted look
                saturation = 0.2, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)

                -- Enable italics comments
                italic_comments = false,

                -- Replace all fillchars with ' ' for the ultimate clean look
                hide_fillchars = false,

                -- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
                borderless_pickers = true,

                -- Set terminal colors used in `:terminal`
                terminal_colors = true,

                -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
                cache = false,

                -- Override highlight groups with your own colour values
                highlights = {
                    -- Highlight groups to override, adding new groups is also possible
                    -- See `:h highlight-groups` for a list of highlight groups or run `:hi` to see all groups and their current values

                    -- Example:
                    Comment = { fg = "#696969", bg = "NONE", italic = true },

                    -- More examples can be found in `lua/cyberdream/extensions/*.lua`
                },

                -- Override a highlight group entirely using the built-in colour palette
                overrides = function(colors) -- NOTE: This function nullifies the `highlights` option
                    -- Example:
                    return {
                        Comment = { fg = colors.green, bg = "NONE", italic = true },
                        ["@property"] = { fg = colors.magenta, bold = true },
                    }
                end,

                -- Override colors
                colors = {
                    -- For a list of colors see `lua/cyberdream/colours.lua`

                    -- Override colors for both light and dark variants
                    bg = "#000000",
                    green = "#00ff00",

                    -- If you want to override colors for light or dark variants only, use the following format:
                    dark = {
                        magenta = "#ff00ff",
                        fg = "#eeeeee",
                    },
                    light = {
                        red = "#ff5c57",
                        cyan = "#5ef1ff",
                    },
                },

                -- Disable or enable colorscheme extensions
                extensions = {
                    telescope = true,
                    notify = true,
                    mini = true,
                },
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
                    keywords = "none",
                    keyword_return = "bold",
                    keywords_loop = "none",
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
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_transparent_background = 2
            vim.g.everforest_better_performance = 1
        end
    },
    {
        "rose-pine/neovim",
        config = function()
            require("rose-pine").setup({
                variant = "main",
                dark_variant = "moon",
                styles = {
                    transparency = true,
                    italic = false
                }
            })
        end
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true,
                styles = {
                    keywords = { bold = true, italic = false }
                }
            })
        end

    },
    {
      "craftzdog/solarized-osaka.nvim",
      lazy = false,
      priority = 1000,
      config = function()
          require("solarized-osaka").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            transparent = true, -- Enable this to disable setting the background color
            terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
            styles = {
              -- Style to be applied to different syntax groups
              -- Value is any valid attr-list value for `:help nvim_set_hl`
              comments = { italic = true },
              keywords = { bold = true },
              functions = {},
              variables = {},
              -- Background styles. Can be "dark", "transparent" or "normal"
              sidebars = "dark", -- style for sidebars, see below
              floats = "dark", -- style for floating windows
            },
            sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
            day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
            hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
            dim_inactive = false, -- dims inactive windows
            lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

            --- You can override specific color groups to use other groups or a hex color
            --- function will be called with a ColorScheme table
            ---@param colors ColorScheme
            on_colors = function(colors) end,

            --- You can override specific highlights to use other groups or a hex color
            --- function will be called with a Highlights and ColorScheme table
            ---@param highlights Highlights
            ---@param colors ColorScheme
            on_highlights = function(highlights, colors) end,
          })
      end
    },
    {
        "nyoom-engineering/oxocarbon.nvim",
        config = function ()
            vim.opt.background = "dark"
        end
    }
}
