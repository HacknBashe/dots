vim.keymap.set("n", "<leader>gg", function()
	local in_tmux = vim.fn.system('[ -n "$TMUX" ] && echo 1 || echo 0'):gsub("%s+", "")

	if in_tmux == "1" then
		vim.fn.system("tmux_lazygit")
	else
		vim.notify("Not running in tmux session", vim.log.levels.WARN)
	end
end, { desc = "Open lazygit in tmux window" })

vim.keymap.set("n", "<leader>fy", function()
	local in_tmux = vim.fn.system('[ -n "$TMUX" ] && echo 1 || echo 0'):gsub("%s+", "")

	if in_tmux == "1" then
		local current_file = vim.fn.expand("%:p")
		local target_path = current_file ~= "" and current_file or vim.fn.getcwd()
		vim.fn.system("tmux_yazi '" .. target_path .. "'")
	else
		-- Fall back to regular Yazi command if not in tmux
		vim.cmd("Yazi")
	end
end, { desc = "Smart Yazi navigation", silent = true, noremap = true })

local function get_buffer_context()
	local buf_name = vim.fn.expand("%:t")
	local buf_path = vim.fn.expand("%:p")
	local selected_text = ""
	local start_line, end_line

	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then -- v, V, or ctrl-v
		local save_reg = vim.fn.getreg('"')
		local save_regtype = vim.fn.getregtype('"')

		-- Yank the selection into the unnamed register
		vim.cmd([[silent normal! "xy]])

		-- Get the text from the unnamed register
		selected_text = vim.fn.getreg("x")

		-- Get start and end positions of selection
		start_line = vim.fn.line("'<")
		end_line = vim.fn.line("'>")

		-- Restore the register
		vim.fn.setreg('"', save_reg, save_regtype)

		-- Add line numbers to the selected text
		local lines = {}
		local line_num = start_line
		for line in selected_text:gmatch("[^\r\n]+") do
			table.insert(lines, string.format("%4d: %s", line_num, line))
			line_num = line_num + 1
		end
		selected_text = table.concat(lines, "\n")
	else
		start_line = vim.fn.line(".")
		end_line = start_line
	end

	local context = string.format("I'm looking at the %s file (%s)", buf_name, buf_path)

	if selected_text ~= "" then
		context = context
			.. string.format(
				" on lines %d to %d.\n\nHere is the selected content:\n%s",
				start_line,
				end_line,
				selected_text
			)
	end

	return context
end

vim.keymap.set({ "n", "v" }, "<leader>ay", function()
	local context = get_buffer_context()
	vim.fn.setreg("+", context)
	print("Nvim AI Context copied to clipboard")

	-- Switch to claude pane in tmux if in tmux session
	if vim.env.TMUX then
		vim.fn.system("tmux_claude '" .. context:gsub("'", "'\\''") .. "'")
	end
end, { desc = "Copy AI info to clipboard" })
