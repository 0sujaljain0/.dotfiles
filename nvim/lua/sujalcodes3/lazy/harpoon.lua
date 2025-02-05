return {
    'ThePrimeagen/harpoon',
    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>a", mark.add_file)
        vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

        vim.keymap.set("n", "<leader>Z", function() ui.nav_file(1) end)
        vim.keymap.set("n", "<leader>N", function() ui.nav_file(2) end)
        vim.keymap.set("n", "<leader>E", function() ui.nav_file(3) end)
        vim.keymap.set("n", "<leader>B", function() ui.nav_file(3) end)
        vim.keymap.set("n", "<leader>Y", function() require("harpoon.term").gotoTerminal(1) end)
    end
}
