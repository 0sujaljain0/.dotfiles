function ColorMyPencils(color)
    color = color or "vague"
    vim.opt.termguicolors = true
    vim.cmd.colorscheme(color)
end

return {
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
                variant = "moon",
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
        "savq/melange-nvim",
    },
    {
        "rktjmp/lush.nvim",
    },
    {
        "arcticicestudio/nord-vim"
    }
}
