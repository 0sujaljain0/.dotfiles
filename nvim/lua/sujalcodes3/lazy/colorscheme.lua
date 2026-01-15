function ColorMyPencils(color)
    color = color or "tokyonight"
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
                    floats = "transparent"
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
    }
}
