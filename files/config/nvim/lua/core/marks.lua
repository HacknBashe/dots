-- marks.lua - Harpoon-like mark management for native uppercase marks
-- Keybinds:
--   <leader>ma - Add next available mark at cursor
--   <leader>vm - View/edit marks in floating buffer
--   <leader>md - Delete mark on current line
--   <leader>mn - Jump to next mark (alphabetically)
--   <leader>mp - Jump to previous mark (alphabetically)

local M = {}

local ns = vim.api.nvim_create_namespace("user_marks")
local mark_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local last_mark = nil -- Track the last mark we jumped to or set

-- Highlight for gutter signs
vim.api.nvim_set_hl(0, "MarkSign", { fg = "#c099ff", bold = true })

---Get all uppercase marks with their positions
---@return table[] marks Array of {mark, file, line, col}
local function get_all_marks()
	local marks = {}
	for i = 1, #mark_letters do
		local letter = mark_letters:sub(i, i)
		local mark = vim.api.nvim_get_mark(letter, {})
		-- mark returns {row, col, buffer, buffername}
		-- row is 0 if mark doesn't exist
		if mark[1] ~= 0 then
			table.insert(marks, {
				mark = letter,
				file = mark[4],
				line = mark[1],
				col = mark[2],
			})
		end
	end
	-- Sort alphabetically by mark letter
	table.sort(marks, function(a, b)
		return a.mark < b.mark
	end)
	return marks
end

---Get marks for a specific buffer
---@param bufnr number Buffer number
---@return table[] marks Array of {mark, line, col}
local function get_buffer_marks(bufnr)
	local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
	local marks = {}
	for i = 1, #mark_letters do
		local letter = mark_letters:sub(i, i)
		local mark = vim.api.nvim_get_mark(letter, {})
		local mark_file = vim.fn.fnamemodify(mark[4], ":p")
		if mark[1] ~= 0 and mark_file == bufname then
			table.insert(marks, {
				mark = letter,
				line = mark[1],
				col = mark[2],
			})
		end
	end
	return marks
end

---Find the next available mark letter
---@return string|nil letter The next available letter, or nil if all used
local function get_next_available_mark()
	local used = {}
	for i = 1, #mark_letters do
		local letter = mark_letters:sub(i, i)
		local mark = vim.api.nvim_get_mark(letter, {})
		if mark[1] ~= 0 then
			used[letter] = true
		end
	end
	for i = 1, #mark_letters do
		local letter = mark_letters:sub(i, i)
		if not used[letter] then
			return letter
		end
	end
	return nil
end

---Update gutter signs for a buffer
---@param bufnr number Buffer number
local function refresh_signs(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	-- Clear existing signs
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	-- Add signs for each mark
	local marks = get_buffer_marks(bufnr)
	for _, m in ipairs(marks) do
		pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, m.line - 1, 0, {
			sign_text = m.mark,
			sign_hl_group = "MarkSign",
			priority = 10,
		})
	end
end

---Refresh signs for all loaded buffers
local function refresh_all_signs()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			refresh_signs(bufnr)
		end
	end
end

---Delete all uppercase marks
local function clear_all_marks()
	vim.cmd("delmarks A-Z")
end

---Get the git root directory
---@return string|nil
local function get_git_root()
	local result = vim.fn.systemlist("git rev-parse --show-toplevel")
	if vim.v.shell_error == 0 and result[1] then
		return result[1]
	end
	return nil
end

---Get the marks file path
---@return string|nil
local function get_marks_file()
	local git_root = get_git_root()
	if git_root then
		return git_root .. "/.git/nvim-marks.json"
	end
	return nil
end

---Save marks to file
local function save_marks()
	local file = get_marks_file()
	if not file then
		return
	end
	local marks = get_all_marks()
	local json = vim.fn.json_encode(marks)
	local f = io.open(file, "w")
	if f then
		f:write(json)
		f:close()
	end
end

---Load marks from file
local function load_marks()
	local file = get_marks_file()
	if not file then
		return
	end
	local f = io.open(file, "r")
	if not f then
		return
	end
	local content = f:read("*a")
	f:close()
	if content == "" then
		return
	end
	local ok, marks = pcall(vim.fn.json_decode, content)
	if not ok or type(marks) ~= "table" then
		return
	end
	-- Save current position
	local save_buf = vim.api.nvim_get_current_buf()
	local save_view = vim.fn.winsaveview()

	for _, m in ipairs(marks) do
		if m.mark and m.file and m.file ~= "" and m.line and m.line > 0 then
			pcall(function()
				vim.cmd("silent! edit " .. vim.fn.fnameescape(m.file))
				local line_count = vim.api.nvim_buf_line_count(0)
				local target_line = math.min(m.line, line_count)
				vim.api.nvim_win_set_cursor(0, { target_line, m.col or 0 })
				vim.cmd("normal! m" .. m.mark)
			end)
		end
	end

	-- Restore position
	pcall(function()
		vim.api.nvim_set_current_buf(save_buf)
		vim.fn.winrestview(save_view)
	end)
	vim.schedule(refresh_all_signs)
end

---Add mark at cursor position
function M.add_mark()
	local letter = get_next_available_mark()
	if not letter then
		print("All marks (A-Z) are in use")
		return
	end
	local line = vim.fn.line(".")
	local col = vim.fn.col(".") - 1
	vim.api.nvim_buf_set_mark(0, letter, line, col, {})
	last_mark = letter
	print(string.format("Set mark '%s' at line %d", letter, line))
	refresh_signs(vim.api.nvim_get_current_buf())
end

---Delete mark on current line
function M.delete_mark_on_line()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_line = vim.fn.line(".")
	local marks = get_buffer_marks(bufnr)
	for _, m in ipairs(marks) do
		if m.line == current_line then
			vim.cmd("delmarks " .. m.mark)
			print(string.format("Deleted mark '%s'", m.mark))
			refresh_signs(bufnr)
			return
		end
	end
	print("No mark on this line")
end

---Jump to next mark alphabetically from last_mark
function M.next_mark()
	local marks = get_all_marks()
	if #marks == 0 then
		print("No marks set")
		return
	end

	-- If no last_mark or it no longer exists, start at first mark
	local start_idx = 1
	if last_mark then
		for i, m in ipairs(marks) do
			if m.mark == last_mark then
				start_idx = i
				break
			end
		end
	end

	-- Next mark (wrap around)
	local next_idx = start_idx + 1
	if next_idx > #marks then
		next_idx = 1
	end

	local next_m = marks[next_idx]
	last_mark = next_m.mark
	vim.cmd("normal! `" .. next_m.mark)
	print(string.format("Mark '%s'%s", next_m.mark, next_idx == 1 and " (wrapped)" or ""))
end

---Jump to previous mark alphabetically from last_mark
function M.prev_mark()
	local marks = get_all_marks()
	if #marks == 0 then
		print("No marks set")
		return
	end

	-- If no last_mark or it no longer exists, start at last mark
	local start_idx = #marks
	if last_mark then
		for i, m in ipairs(marks) do
			if m.mark == last_mark then
				start_idx = i
				break
			end
		end
	end

	-- Previous mark (wrap around)
	local prev_idx = start_idx - 1
	if prev_idx < 1 then
		prev_idx = #marks
	end

	local prev_m = marks[prev_idx]
	last_mark = prev_m.mark
	vim.cmd("normal! `" .. prev_m.mark)
	print(string.format("Mark '%s'%s", prev_m.mark, prev_idx == #marks and " (wrapped)" or ""))
end

---View and edit marks in floating buffer
function M.view_marks()
	local marks = get_all_marks()

	-- Create buffer content
	local lines = {}
	local max_path_len = 0
	for _, m in ipairs(marks) do
		local rel_path = vim.fn.fnamemodify(m.file, ":~:.")
		if #rel_path > max_path_len then
			max_path_len = #rel_path
		end
	end
	max_path_len = math.min(max_path_len, 50) -- cap width

	for _, m in ipairs(marks) do
		local rel_path = vim.fn.fnamemodify(m.file, ":~:.")
		if #rel_path > 50 then
			rel_path = "..." .. rel_path:sub(-47)
		end
		-- Try to get line content by reading file directly
		local line_content = ""
		local full_path = vim.fn.fnamemodify(m.file, ":p")
		if vim.fn.filereadable(full_path) == 1 then
			local ok, file_lines = pcall(vim.fn.readfile, full_path, "", m.line)
			if ok and file_lines and file_lines[m.line] then
				line_content = vim.trim(file_lines[m.line]):sub(1, 60)
			end
		end
		table.insert(lines, string.format("%s | %-" .. max_path_len .. "s:%d | %s", m.mark, rel_path, m.line, line_content))
	end

	if #lines == 0 then
		print("No marks set")
		return
	end

	-- Create floating buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = true
	vim.bo[buf].filetype = "marks"

	-- Calculate window size
	local width = math.min(math.floor(vim.o.columns * 0.8), 120)
	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.6))
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		border = "rounded",
		style = "minimal",
		title = " Marks (edit & close to apply) ",
		title_pos = "center",
	})

	vim.wo[win].number = true
	vim.wo[win].cursorline = true

	-- Create a lookup table: original mark letter -> mark data
	local mark_lookup = {}
	for _, m in ipairs(marks) do
		mark_lookup[m.mark] = { file = m.file, line = m.line, col = m.col }
	end

	-- Apply changes from a list of lines
	local function apply_changes(new_lines)
		-- Parse remaining lines to get mark data in new order
		local remaining = {}
		for _, line in ipairs(new_lines) do
			local mark_letter = line:match("^(%u)")
			if mark_letter and mark_lookup[mark_letter] then
				table.insert(remaining, mark_lookup[mark_letter])
			end
		end

		-- Don't do anything if nothing to apply
		if #remaining == 0 then
			return remaining
		end

		-- Clear all marks
		clear_all_marks()

		-- Save current position
		local save_buf = vim.api.nvim_get_current_buf()
		local save_view = vim.fn.winsaveview()

		-- Reassign in new order using native vim commands
		for i, m in ipairs(remaining) do
			local new_letter = mark_letters:sub(i, i)
			if m.file and m.file ~= "" and m.line and m.line > 0 then
				pcall(function()
					-- Open the file
					vim.cmd("silent! edit " .. vim.fn.fnameescape(m.file))
					-- Move to the line/col
					local line_count = vim.api.nvim_buf_line_count(0)
					local target_line = math.min(m.line, line_count)
					vim.api.nvim_win_set_cursor(0, { target_line, m.col })
					-- Set the mark using native command
					vim.cmd("normal! m" .. new_letter)
				end)
			end
		end

		-- Restore position
		vim.api.nvim_set_current_buf(save_buf)
		vim.fn.winrestview(save_view)

		refresh_all_signs()
		return remaining
	end

	-- Close window and apply changes
	local function close_and_apply()
		local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.api.nvim_win_close(win, true)
		local remaining = apply_changes(new_lines)
		print(string.format("Applied %d marks", #remaining))
	end

	-- Keymaps for the floating buffer
	local close_keys = { "q", "<Esc>" }
	for _, key in ipairs(close_keys) do
		vim.keymap.set("n", key, close_and_apply, { buffer = buf, nowait = true })
	end

	-- Enter: save changes and jump to the mark on cursor line
	vim.keymap.set("n", "<CR>", function()
		-- Get the mark letter on current line BEFORE closing
		local current_line_content = vim.api.nvim_get_current_line()
		local mark_letter = current_line_content:match("^(%u)")
		local jump_target = mark_letter and mark_lookup[mark_letter]

		-- Get the line index to determine new mark letter after reorder
		local cursor_line_idx = vim.fn.line(".")

		-- Read all lines before closing (buffer gets wiped on close)
		local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.api.nvim_win_close(win, true)
		apply_changes(new_lines)

		-- Jump directly to the stored position
		if jump_target then
			vim.cmd("edit " .. vim.fn.fnameescape(jump_target.file))
			vim.api.nvim_win_set_cursor(0, { jump_target.line, jump_target.col })
			-- Set last_mark to the new letter at this position (based on line order)
			last_mark = mark_letters:sub(cursor_line_idx, cursor_line_idx)
		end
	end, { buffer = buf, nowait = true })
end

-- Setup autocommands
local augroup = vim.api.nvim_create_augroup("UserMarks", { clear = true })

-- Clear marks on startup, then load from file
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = function()
		clear_all_marks()
		vim.schedule(load_marks)
	end,
})

-- Save marks on exit
vim.api.nvim_create_autocmd("VimLeave", {
	group = augroup,
	callback = save_marks,
})

-- Refresh signs on buffer enter and CursorHold (catches native m{letter} usage)
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
	group = augroup,
	callback = function()
		refresh_signs(vim.api.nvim_get_current_buf())
	end,
})

-- Keymaps
local function opts(desc)
	return { desc = desc, noremap = true, silent = true, nowait = true }
end

vim.keymap.set("n", "<leader>ma", M.add_mark, opts("Add mark at cursor"))
vim.keymap.set("n", "<leader>vm", M.view_marks, opts("View marks"))
vim.keymap.set("n", "<leader>md", M.delete_mark_on_line, opts("Delete mark on line"))
vim.keymap.set("n", "<leader>mn", M.next_mark, opts("Next mark"))
vim.keymap.set("n", "<leader>mp", M.prev_mark, opts("Previous mark"))

return M
