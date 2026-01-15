local M = {}

-- Track the TODO finder buffer to avoid conflicts
local todo_finder_bufnr = nil

-- Track expanded TODOs (set of TODO indices)
local expanded_todos = {}

-- Default configuration
local default_config = {
	keywords = {
		TODO = { icon = "󰄱 ", color = "InfoMsg" },
		FIXME = { icon = "󰒡 ", color = "ErrorMsg" },
		HACK = { icon = "󰒉 ", color = "WarningMsg" },
		WARN = { icon = "󰀪 ", color = "WarningMsg" },
		PERF = { icon = "󰅒 ", color = "WarningMsg" },
		NOTE = { icon = "󰎔 ", color = "InfoMsg" },
		TEST = { icon = "󰙨 ", color = "InfoMsg" },
	},
	-- File patterns to exclude (glob patterns)
	exclude_patterns = {
		"node_modules/**",
		".git/**",
		"**/target/**",
		"**/dist/**",
		"**/build/**",
	},
	-- File types to exclude
	exclude_filetypes = {},
}

M.config = default_config

-- Set configuration
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

-- Get all TODO items from a file using treesitter
local function get_todos_from_file(filepath)
	local todos = {}
	
	-- Read file content
	local ok, lines = pcall(vim.fn.readfile, filepath)
	if not ok then
		return todos
	end
	
	local content = table.concat(lines, "\n")
	
	-- Get filetype
	local ft = vim.filetype.match({ filename = filepath })
	if not ft or ft == "" then
		-- Try to detect from extension
		local ext = vim.fn.fnamemodify(filepath, ":e")
		if ext ~= "" then
			ft = vim.filetype.match({ filename = "." .. ext })
		end
	end
	
	if not ft or ft == "" then
		return todos
	end
	
	-- Check if treesitter parser is available
	local ts_ok, ts = pcall(require, "nvim-treesitter")
	if not ts_ok then
		return todos
	end
	
	local parsers_ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if not parsers_ok then
		return todos
	end
	
	-- Check if parser exists for this filetype
	if not parsers.has_parser(ft) then
		return todos
	end
	
	-- Create a temporary buffer to parse
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(bufnr, "filetype", ft)
	
	-- Get the parser
	local parser = parsers.get_parser(bufnr, ft)
	if not parser then
		vim.api.nvim_buf_delete(bufnr, { force = true })
		return todos
	end
	
	-- Parse the buffer
	parser:parse()
	local tree = parser:trees()[1]
	if not tree then
		vim.api.nvim_buf_delete(bufnr, { force = true })
		return todos
	end
	
	local root = tree:root()
	
	-- Function to extract TODOs from comment text
	local function extract_todos_from_text(comment_text, start_row, start_col)
		-- Normalize comment text: remove common comment prefixes
		local normalized_text = comment_text:gsub("^%s*//+%s*", ""):gsub("^%s*#+%s*", ""):gsub("^%s*%-%-+%s*", ""):gsub("^%s*%*+%s*", "")
		normalized_text = normalized_text:gsub("^%s*", ""):gsub("%s*$", "")
		
		-- Try both normalized and original text
		local texts_to_check = { normalized_text, comment_text }
		
		for keyword, opts in pairs(M.config.keywords) do
			for _, text in ipairs(texts_to_check) do
				-- Check if keyword exists in the text (case-sensitive)
				local keyword_pos = text:find(keyword, 1, true) -- plain search, case-sensitive
				if keyword_pos then
					-- Extract everything after the keyword (handles "TODO:", "TODO :", "TODO ")
					local after_keyword = text:sub(keyword_pos + #keyword)
					-- Remove leading whitespace and colon if present
					after_keyword = after_keyword:gsub("^%s*:?%s*", "")
					
					if after_keyword and after_keyword ~= "" then
						-- Clean up the text
						after_keyword = after_keyword:gsub("^%s+", ""):gsub("%s+$", "")
						
						-- Treesitter range() returns 0-indexed values
						-- Convert to 1-indexed for Neovim
						local line_num = start_row + 1
						local col_num = start_col + 1
						
						-- Ensure line number is at least 1
						line_num = math.max(1, line_num)
						col_num = math.max(1, col_num)
						
						return {
							file = filepath,
							line = line_num,
							col = col_num,
							keyword = keyword,
							icon = opts.icon,
							color = opts.color,
							text = after_keyword,
							full_comment = comment_text,
							file_lines = lines, -- Store file lines for context
						}
					end
				end
			end
		end
		return nil
	end
	
	-- Traverse tree to find comment nodes
	local function find_comments(node)
		local comments = {}
		
		-- Check if this node is a comment
		-- Different languages use different comment node types:
		-- - "comment" (generic)
		-- - "line_comment" (e.g., // in C, JavaScript)
		-- - "block_comment" (e.g., /* */ in C)
		-- - "comment_line" (some languages)
		-- - "line_comment_directive" (some languages)
		local node_type = node:type()
		local is_comment = node_type == "comment" 
			or node_type == "line_comment" 
			or node_type == "block_comment"
			or node_type == "comment_line"
			or node_type == "line_comment_directive"
			or node_type:match("comment")
		
		if is_comment then
			table.insert(comments, node)
		end
		
		-- Recursively check children
		for child in node:iter_children() do
			local child_comments = find_comments(child)
			for _, comment in ipairs(child_comments) do
				table.insert(comments, comment)
			end
		end
		
		return comments
	end
	
	local comment_nodes = find_comments(root)
	
	-- Extract TODO keywords from comments
	for _, comment_node in ipairs(comment_nodes) do
		local start_row, start_col, end_row, end_col = comment_node:range()
		local comment_text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
		comment_text = table.concat(comment_text, "\n")
		
		local todo = extract_todos_from_text(comment_text, start_row, start_col)
		if todo then
			table.insert(todos, todo)
		end
	end
	
	vim.api.nvim_buf_delete(bufnr, { force = true })
	return todos
end

-- Check if file should be excluded
local function should_exclude_file(filepath)
	-- Check filetype
	local ft = vim.filetype.match({ filename = filepath })
	for _, exclude_ft in ipairs(M.config.exclude_filetypes) do
		if ft == exclude_ft then
			return true
		end
	end
	
	-- Check patterns (simple string matching)
	local normalized_path = filepath:gsub("\\", "/")
	for _, pattern in ipairs(M.config.exclude_patterns) do
		-- Convert glob pattern to lua pattern
		local lua_pattern = pattern:gsub("%*", ".*"):gsub("%?", ".")
		if normalized_path:match(lua_pattern) then
			return true
		end
	end
	
	return false
end

-- Get all files in the project
local function get_project_files(root_dir)
	local files = {}
	
	-- Use glob to find all files recursively
	local all_files = vim.fn.globpath(root_dir, "**/*", false, true)
	
	for _, file in ipairs(all_files) do
		-- Skip directories (they end with /)
		if not file:match("/$") then
			-- Check if it's a regular file (simple check)
			local ok, stat = pcall(vim.loop.fs_stat, file)
			if ok and stat and stat.type == "file" then
				if not should_exclude_file(file) then
					table.insert(files, file)
				end
			end
		end
	end
	
	return files
end

-- Find all TODOs in the project (with progress callback)
function M.find_all_todos(root_dir, progress_callback)
	root_dir = root_dir or vim.fn.getcwd()
	local files = get_project_files(root_dir)
	local all_todos = {}
	local total_files = #files
	
	for i, file in ipairs(files) do
		-- Call progress callback if provided
		if progress_callback then
			progress_callback(i, total_files, file)
		end
		
		local todos = get_todos_from_file(file)
		for _, todo in ipairs(todos) do
			table.insert(all_todos, todo)
		end
	end
	
	return all_todos
end

-- Create loading buffer
local function create_loading_buffer()
	local buffer_name = "TODO Finder"
	local bufnr = nil
	
	-- Check if we have a tracked buffer that's still valid
	if todo_finder_bufnr and vim.api.nvim_buf_is_valid(todo_finder_bufnr) then
		bufnr = todo_finder_bufnr
		-- Clear existing content
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
	else
		-- Check if buffer with this name exists
		local existing_bufnr = nil
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) then
				local buf_name = vim.api.nvim_buf_get_name(buf)
				if buf_name == buffer_name then
					existing_bufnr = buf
					break
				end
			end
		end
		
		if existing_bufnr then
			bufnr = existing_bufnr
			-- Clear existing content
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
		else
			-- Create new buffer
			bufnr = vim.api.nvim_create_buf(false, true)
			-- Try to set the name
			local ok = pcall(vim.api.nvim_buf_set_name, bufnr, buffer_name)
			-- If it fails, that's okay - we'll still use the buffer
		end
		
		-- Track the buffer
		todo_finder_bufnr = bufnr
	end
	
	-- Set buffer options (these should always work)
	vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "todofinder")
	
	return bufnr
end

-- Update loading buffer with progress
local function update_loading_buffer(bufnr, current, total, current_file)
	local width = 80
	local lines = {}
	local header = "┌" .. string.rep("─", width - 2) .. "┐"
	local footer = "└" .. string.rep("─", width - 2) .. "┘"
	
	table.insert(lines, header)
	table.insert(lines, "│" .. string.format(" TODO Finder - Scanning..." .. string.rep(" ", width - 28) .. "│"))
	table.insert(lines, "├" .. string.rep("─", width - 2) .. "┤")
	
	local progress = math.floor((current / total) * 100)
	local progress_bar_width = width - 10
	local filled = math.floor((current / total) * progress_bar_width)
	local bar = "[" .. string.rep("█", filled) .. string.rep("░", progress_bar_width - filled) .. "]"
	
	table.insert(lines, "│ " .. bar .. string.format(" %d%%", progress) .. string.rep(" ", width - #bar - 6) .. "│")
	table.insert(lines, "├" .. string.rep("─", width - 2) .. "┤")
	
	local file_text = string.format(" Scanning: %s", current_file)
	if #file_text > width - 4 then
		file_text = file_text:sub(1, width - 7) .. "..."
	end
	table.insert(lines, "│" .. file_text .. string.rep(" ", width - #file_text - 2) .. "│")
	table.insert(lines, "│" .. string.format(" Files: %d / %d" .. string.rep(" ", width - 15 - #tostring(current) - #tostring(total)) .. "│", current, total))
	table.insert(lines, footer)
	
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

-- Create and show TODO buffer
function M.show_todos(root_dir)
	root_dir = root_dir or vim.fn.getcwd()
	
	-- Reset expanded TODOs
	expanded_todos = {}
	
	-- Create loading buffer first
	local bufnr = create_loading_buffer()
	
	local width = 100
	local height = 10
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	}
	
	-- Check if window already exists
	local existing_win = nil
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			existing_win = win
			break
		end
	end
	
	local win
	if existing_win and vim.api.nvim_win_is_valid(existing_win) then
		win = existing_win
	else
		win = vim.api.nvim_open_win(bufnr, true, win_opts)
	end
	
	-- Show initial loading state
	update_loading_buffer(bufnr, 0, 1, "Starting scan...")
	vim.api.nvim_win_set_option(win, "cursorline", false)
	
	-- Force redraw
	vim.cmd("redraw")
	
	-- Find todos with progress updates
	local todos = {}
	local files = get_project_files(root_dir)
	local total_files = #files
	
	for i, file in ipairs(files) do
		-- Update progress
		local rel_file = vim.fn.fnamemodify(file, ":~:.")
		update_loading_buffer(bufnr, i, total_files, rel_file)
		vim.cmd("redraw")
		
		local file_todos = get_todos_from_file(file)
		for _, todo in ipairs(file_todos) do
			table.insert(todos, todo)
		end
	end
	
	-- Now display the results with modern UI
	local function build_ui_lines()
		local ui_lines = {}
		local ui_width = 100
		
		-- Header
		table.insert(ui_lines, "╭" .. string.rep("─", ui_width - 2) .. "╮")
		table.insert(ui_lines, "│" .. " TODO Finder" .. string.rep(" ", ui_width - 14) .. "│")
		table.insert(ui_lines, "├" .. string.rep("─", ui_width - 2) .. "┤")
		
		-- Count
		local count_text = string.format("Found %d TODO%s", #todos, #todos == 1 and "" or "s")
		table.insert(ui_lines, "│ " .. count_text .. string.rep(" ", ui_width - #count_text - 3) .. "│")
		table.insert(ui_lines, "├" .. string.rep("─", ui_width - 2) .. "┤")
		table.insert(ui_lines, "")
		
		if #todos == 0 then
			table.insert(ui_lines, "│" .. string.rep(" ", math.floor((ui_width - 2) / 2) - 10) .. "No TODOs found" .. string.rep(" ", math.floor((ui_width - 2) / 2) - 10) .. "│")
		else
			for i, todo in ipairs(todos) do
				local rel_path = vim.fn.fnamemodify(todo.file, ":~:.")
				local display_text = todo.text ~= "" and todo.text or "(no description)"
				
				-- Format: [icon] KEYWORD                    file:line
				--         description text here...
				local keyword_line = string.format("  %s %s", todo.icon, todo.keyword)
				local file_info = string.format("%s:%d", rel_path, todo.line)
				local file_info_padded = string.rep(" ", ui_width - #keyword_line - #file_info - 4) .. file_info
				table.insert(ui_lines, keyword_line .. file_info_padded)
				
				-- Description on next line with indentation
				local desc_line = "    " .. display_text
				if #desc_line > ui_width - 4 then
					desc_line = desc_line:sub(1, ui_width - 7) .. "..."
				end
				table.insert(ui_lines, desc_line)
				
				-- Show context if expanded
				if expanded_todos[i] and todo.file_lines then
					local context_lines_before = 3
					local context_lines_after = 3
					local todo_line_idx = todo.line - 1
					local file_lines = todo.file_lines
					local total_lines = #file_lines
					
					local start_line = math.max(1, todo_line_idx - context_lines_before + 1)
					local end_line = math.min(total_lines, todo_line_idx + context_lines_after + 1)
					
					table.insert(ui_lines, "")
					table.insert(ui_lines, "    ┌─ Context ─" .. string.rep("─", ui_width - 18) .. "┐")
					
					for ctx_line_idx = start_line, end_line do
						local ctx_line_num = ctx_line_idx
						local ctx_line_text = file_lines[ctx_line_idx] or ""
						
						-- Clean up leading/trailing whitespace
						ctx_line_text = ctx_line_text:gsub("^%s+", ""):gsub("%s+$", "")
						
						-- Truncate if too long
						if #ctx_line_text > ui_width - 20 then
							ctx_line_text = ctx_line_text:sub(1, ui_width - 23) .. "..."
						end
						
						-- Highlight the TODO line
						local marker = (ctx_line_idx == todo.line) and "▶" or " "
						local line_num_str = string.format("%4d", ctx_line_num)
						local context_line = string.format("    │ %s %s │ %s", marker, line_num_str, ctx_line_text)
						context_line = context_line .. string.rep(" ", math.max(0, ui_width - #context_line - 4)) .. "│"
						table.insert(ui_lines, context_line)
					end
					
					table.insert(ui_lines, "    └" .. string.rep("─", ui_width - 6) .. "┘")
				end
				
				-- Separator between TODOs (except last)
				if i < #todos then
					table.insert(ui_lines, "")
					table.insert(ui_lines, "  " .. string.rep("─", ui_width - 4))
					table.insert(ui_lines, "")
				end
			end
		end
		
		table.insert(ui_lines, "")
		table.insert(ui_lines, "╰" .. string.rep("─", ui_width - 2) .. "╯")
		table.insert(ui_lines, "")
		table.insert(ui_lines, "  j/k: Navigate  │  e: Expand  │  <Enter>: Jump  │  q/<Esc>: Close")
		
		return ui_lines, ui_width
	end
	
	local lines, ui_width = build_ui_lines()
	width = ui_width -- Update width for window sizing
	
	-- Function to rebuild and redraw the buffer
	local function redraw_buffer()
		local new_lines, new_width = build_ui_lines()
		width = new_width -- Update width
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
		-- Resize window if needed
		local new_height = math.min(#new_lines, vim.o.lines - 4)
		vim.api.nvim_win_set_width(win, new_width)
		vim.api.nvim_win_set_height(win, new_height)
		return new_lines
	end
	
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	
	-- Calculate TODO item line range (will be updated when redrawing)
	-- Header: title (2 lines) + separator + count (2 lines) + separator + blank = 6 lines
	local header_lines = 6
	local function calculate_todo_lines()
		local current_todo_start = header_lines + 1
		local current_todo_end = current_todo_start
		
		for i = 1, #todos do
			current_todo_end = current_todo_end
			if expanded_todos[i] and todos[i].file_lines then
				-- Add context lines (3 before + 3 after + 1 for the TODO line itself = 7)
				current_todo_end = current_todo_end + 6
			else
				current_todo_end = current_todo_end
			end
			if i < #todos then
				current_todo_end = current_todo_end + 1
			end
		end
		
		return current_todo_start, current_todo_start + #todos - 1
	end
	
	local todo_start_line, todo_end_line = calculate_todo_lines()
	
	-- Helper function to get TODO index from current line (accounts for new UI structure)
	local function get_todo_index_from_line(line_num)
		local current_line = header_lines + 1
		for i = 1, #todos do
			-- Each TODO takes 2 lines (keyword + description)
			local todo_start = current_line
			local todo_end = current_line + 1
			
			-- Check if cursor is on this TODO's lines
			if line_num >= todo_start and line_num <= todo_end then
				return i
			end
			
			-- Check if cursor is in this TODO's expanded context
			if expanded_todos[i] and todos[i].file_lines then
				local context_start = todo_end + 1
				local context_end = context_start + 6 -- Context box + lines
				if line_num >= context_start and line_num <= context_end then
					return i
				end
				current_line = context_end + 1
			else
				current_line = todo_end + 1
			end
			
			-- Add separator if not last TODO
			if i < #todos then
				current_line = current_line + 2 -- separator line + blank
			end
			
			-- If we've passed the line, return previous TODO
			if line_num < current_line then
				return i
			end
		end
		return nil
	end
	
	-- Helper function to get line number from TODO index (accounts for new UI structure)
	local function get_line_from_todo_index(todo_index)
		if todo_index < 1 or todo_index > #todos then
			return nil
		end
		local line = header_lines + 1
		for i = 1, todo_index - 1 do
			line = line + 2 -- Each TODO takes 2 lines
			if expanded_todos[i] and todos[i].file_lines then
				line = line + 8 -- Context box (1 line) + 6 context lines + 1 closing
			end
			if i < #todos then
				line = line + 2 -- separator + blank
			end
		end
		return line
	end
	
	-- Navigation functions
	local function navigate_todos(direction)
		local current_win = vim.api.nvim_get_current_win()
		local current_line = vim.api.nvim_win_get_cursor(current_win)[1]
		
		-- Use the helper function to get current index
		local current_index = get_todo_index_from_line(current_line)
		
		-- If not on a TODO line, start at first/last TODO
		if not current_index then
			if direction > 0 then
				current_index = 0  -- Will become 1
			else
				current_index = #todos + 1  -- Will become #todos
			end
		end
		
		-- Calculate new index
		local new_index = current_index + direction
		
		-- Clamp to valid range
		if new_index < 1 then
			new_index = 1
		elseif new_index > #todos then
			new_index = #todos
		end
		
		-- Move cursor to the TODO line (recalculate after potential redraw)
		local target_line = get_line_from_todo_index(new_index)
		if target_line then
			vim.api.nvim_win_set_cursor(current_win, { target_line, 0 })
		end
	end
	
	-- Set up keybindings
	local function jump_to_todo()
		local current_win = vim.api.nvim_get_current_win()
		local line_num = vim.api.nvim_win_get_cursor(current_win)[1]
		local todo_index = get_todo_index_from_line(line_num)
		
		-- If not on a TODO line, try to get the closest one
		if not todo_index then
			if line_num < todo_start_line then
				todo_index = 1
			elseif line_num > todo_end_line then
				todo_index = #todos
			else
				return  -- Can't determine which TODO
			end
		end
		
		if todo_index >= 1 and todo_index <= #todos then
			local todo = todos[todo_index]
			
			-- Close the TODO finder window first
			if vim.api.nvim_win_is_valid(current_win) then
				vim.api.nvim_win_close(current_win, false)
			end
			
			-- Ensure we have valid line and column numbers
			local target_line = math.max(1, todo.line or 1)
			local target_col = math.max(0, (todo.col or 1) - 1)
			
			-- Get absolute path
			local file_path = vim.fn.fnamemodify(todo.file, ":p")
			
			-- Open the file and jump to the line using :edit +line
			-- This ensures we jump to the correct line
			local cmd = string.format("edit +%d %s", target_line, vim.fn.fnameescape(file_path))
			vim.cmd(cmd)
			
			-- Wait a moment for the file to load, then set cursor position
			vim.schedule(function()
				local win = vim.api.nvim_get_current_win()
				local bufnr = vim.api.nvim_get_current_buf()
				
				if vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(bufnr) then
					local buf_line_count = vim.api.nvim_buf_line_count(bufnr)
					
					-- Ensure line number is within bounds
					local safe_line = math.min(math.max(1, target_line), buf_line_count)
					local safe_col = math.max(0, target_col)
					
					-- Verify we're in the correct buffer
					local current_file = vim.api.nvim_buf_get_name(bufnr)
					if current_file == file_path or vim.fn.fnamemodify(current_file, ":p") == file_path then
						-- Set cursor position
						vim.api.nvim_win_set_cursor(win, { safe_line, safe_col })
						vim.cmd("normal! zz")
					end
				end
			end)
		end
	end
	
	-- Clear old keymaps and set new ones
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "", {
		callback = jump_to_todo,
		desc = "Jump to TODO",
		noremap = true,
		silent = true,
	})
	
	-- Expand/collapse function
	local function toggle_expand()
		local current_win = vim.api.nvim_get_current_win()
		local current_line = vim.api.nvim_win_get_cursor(current_win)[1]
		local todo_index = get_todo_index_from_line(current_line)
		
		if todo_index and todo_index >= 1 and todo_index <= #todos then
			-- Toggle expansion state
			if expanded_todos[todo_index] then
				expanded_todos[todo_index] = nil
			else
				expanded_todos[todo_index] = true
			end
			
			-- Redraw buffer
			redraw_buffer()
			
			-- Restore cursor position on the TODO line
			local new_line = get_line_from_todo_index(todo_index)
			if new_line then
				vim.api.nvim_win_set_cursor(current_win, { new_line, 0 })
			end
		end
	end
	
	-- Navigation: j/k to move between TODOs
	vim.api.nvim_buf_set_keymap(bufnr, "n", "j", "", {
		callback = function() navigate_todos(1) end,
		desc = "Next TODO",
		noremap = true,
		silent = true,
	})
	vim.api.nvim_buf_set_keymap(bufnr, "n", "k", "", {
		callback = function() navigate_todos(-1) end,
		desc = "Previous TODO",
		noremap = true,
		silent = true,
	})
	
	-- Expand/collapse keybinding
	vim.api.nvim_buf_set_keymap(bufnr, "n", "e", "", {
		callback = toggle_expand,
		desc = "Expand/Collapse TODO context",
		noremap = true,
		silent = true,
	})
	
	-- Also support arrow keys
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Down>", "", {
		callback = function() navigate_todos(1) end,
		desc = "Next TODO",
		noremap = true,
		silent = true,
	})
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Up>", "", {
		callback = function() navigate_todos(-1) end,
		desc = "Previous TODO",
		noremap = true,
		silent = true,
	})
	
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", ":q<CR>", { desc = "Close", noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":q<CR>", { desc = "Close", noremap = true, silent = true })
	
	-- Resize window to fit content
	local new_height = math.min(#lines, vim.o.lines - 4)
	vim.api.nvim_win_set_height(win, new_height)
	vim.api.nvim_win_set_option(win, "cursorline", true)
	
	-- Set cursor to first TODO item initially
	if #todos > 0 then
		vim.api.nvim_win_set_cursor(win, { todo_start_line, 0 })
	end
	
	-- Store todos and metadata in buffer variable for later access
	vim.api.nvim_buf_set_var(bufnr, "todos", todos)
	vim.api.nvim_buf_set_var(bufnr, "todo_start_line", todo_start_line)
	vim.api.nvim_buf_set_var(bufnr, "todo_end_line", todo_end_line)
end

return M

