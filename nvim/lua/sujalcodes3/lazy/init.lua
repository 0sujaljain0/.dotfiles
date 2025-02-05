return {
	{ "nvim-lua/plenary.nvim", priority = 1000 },
	"christoomey/vim-tmux-navigator",
	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},
    {
        "echasnovski/mini.nvim",
        config = function()
            local statusline = require("mini.statusline");
            statusline.setup { use_icons = true }
        end
    },
	{
		"rbong/vim-flog",
		lazy = true,
		cmd = { "Flog", "Flogsplit", "Floggit" },
		dependencies = {
			"tpope/vim-fugitive",
		},
	},
}
