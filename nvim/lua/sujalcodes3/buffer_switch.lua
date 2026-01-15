-- Buffer Switch Plugin for Neovim
-- Allows switching the current buffer to edit a different file

local M = {}

-- Function to switch buffer to a different file
function M.switch_to_file(new_path)
    local current_path = vim.fn.expand('%:p')
    
    -- If no new path is provided, use the current path as default
    if new_path == nil or new_path == '' then
        new_path = current_path
    end
    
    -- Expand the new path to handle ~ and relative paths
    new_path = vim.fn.expand(new_path)
    
    -- If the new path is the same as current path, do nothing
    if new_path == current_path then
        vim.notify("Already editing this file", vim.log.levels.INFO)
        return
    end
    
    -- Check if current buffer has unsaved changes
    if vim.bo.modified then
        local choice = vim.fn.confirm("Current buffer has unsaved changes. Save before switching?", "&Yes\n&No\n&Cancel", 3)
        if choice == 1 then
            vim.cmd('write')
        elseif choice == 3 then
            return
        end
    end
    
    -- Edit the new file in the current buffer
    vim.cmd('edit ' .. vim.fn.fnameescape(new_path))
    vim.notify("Now editing: " .. new_path, vim.log.levels.INFO)
end

-- Function to prompt for new file with command line completion
function M.switch_file_prompt()
    local current_path = vim.fn.expand('%:p')
    
    -- Create a command-line prompt with the current path as default
    vim.ui.input({
        prompt = 'Switch to file: ',
        default = current_path,
        completion = 'file',
    }, function(new_path)
        if new_path then
            M.switch_to_file(new_path)
        end
    end)
end

-- Function to switch to a file in the same directory
function M.switch_in_directory_prompt()
    local current_dir = vim.fn.expand('%:p:h')
    local current_name = vim.fn.expand('%:t')
    
    vim.ui.input({
        prompt = 'File in ' .. current_dir .. ': ',
        default = current_name,
        completion = 'file',
    }, function(new_name)
        if new_name and new_name ~= '' then
            local new_path = current_dir .. '/' .. new_name
            M.switch_to_file(new_path)
        end
    end)
end

-- Setup function to create commands
function M.setup()
    -- Create the main SwitchFile command
    vim.api.nvim_create_user_command('SwitchFile', function(opts)
        if opts.args and opts.args ~= '' then
            M.switch_to_file(opts.args)
        else
            M.switch_file_prompt()
        end
    end, {
        nargs = '?',
        complete = 'file',
        desc = 'Switch current buffer to edit a different file'
    })
    
    -- Create a SwitchInDir command for switching to files in the same directory
    vim.api.nvim_create_user_command('SwitchInDir', function()
        M.switch_in_directory_prompt()
    end, {
        desc = 'Switch to a different file in the same directory'
    })
    
    -- Create shorter aliases
    vim.api.nvim_create_user_command('SF', function(opts)
        if opts.args and opts.args ~= '' then
            M.switch_to_file(opts.args)
        else
            M.switch_file_prompt()
        end
    end, {
        nargs = '?',
        complete = 'file',
        desc = 'Alias for SwitchFile'
    })
    
    vim.api.nvim_create_user_command('SID', function()
        M.switch_in_directory_prompt()
    end, {
        desc = 'Alias for SwitchInDir'
    })
    
    -- Alternative command that's more intuitive
    vim.api.nvim_create_user_command('EditFile', function(opts)
        if opts.args and opts.args ~= '' then
            M.switch_to_file(opts.args)
        else
            M.switch_file_prompt()
        end
    end, {
        nargs = '?',
        complete = 'file',
        desc = 'Edit a different file in the current buffer'
    })
    
    vim.api.nvim_create_user_command('EF', function(opts)
        if opts.args and opts.args ~= '' then
            M.switch_to_file(opts.args)
        else
            M.switch_file_prompt()
        end
    end, {
        nargs = '?',
        complete = 'file',
        desc = 'Alias for EditFile'
    })
end

return M
