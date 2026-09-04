local M = {}

function M.run_command_to_scratch_buffer(cmd, read_only, filetype)
    local output = vim.fn.system(cmd)
    local lines = vim.split(output, "\n")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.cmd("vsplit")

    vim.api.nvim_win_set_buf(0, buf)

    vim.bo[buf].filetype = filetype
    vim.bo[buf].readonly = read_only
    vim.bo[buf].modifiable = not read_only
end

return M
