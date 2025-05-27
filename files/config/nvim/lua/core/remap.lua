vim.g.mapleader = " "

-- keep screen in place
vim.keymap.set("n", "J", "mzJ`z")
-- keep screen centered while paging
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Move highighted lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- delete and paste
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Super Delete and Paste" })
-- paste on new line
vim.keymap.set("n", "<leader>o", ":put<CR>", { desc = "Paste below" })
vim.keymap.set("n", "<leader>O", ":-1put<CR>", { desc = "Paste above" })

-- super delete
vim.keymap.set({ "n", "v" }, "<leader>x", [["_d]], { desc = "Super Delete" })

-- yank to clipboard
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank Line to clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })

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

	-- Switch to claude window in tmux if in tmux session
	if vim.env.TMUX then
		vim.fn.system("tmux select-window -t claude")
		-- Load clipboard into tmux buffer and paste
		vim.fn.system("wl-paste | tmux load-buffer -")
		vim.fn.system("tmux send-keys -t claude i")
		os.execute("sleep 0.1")
		vim.fn.system("tmux send-keys -t claude C-c")
		vim.fn.system("tmux paste-buffer -t claude") -- Paste from tmux buffer
		os.execute("sleep 0.1")
		vim.fn.system("tmux send-keys -t claude Escape")
		os.execute("sleep 0.1")
		vim.fn.system("tmux send-keys -t claude G")
		vim.fn.system("tmux send-keys -t claude o")
	end
end, { desc = "Copy AI info to clipboard" })

-- substitute
vim.keymap.set(
	"v",
	"<Leader>s",
	[["ry:<C-u>%s/<C-r>r/<C-r>r/gI<Left><Left><Left>]],
	{ desc = "Substitute Word Under Cursor", noremap = true, silent = false }
)
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Substitute Selection", noremap = true, silent = false }
)
-- TODO: Add v(isual) s(ubstitute)

-- UI
-- Tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>td", ":tabclose<CR>", { desc = "Delete tab" })

--quickfix
vim.keymap.set("n", "<leader>vq", ":copen<CR>", { desc = "View Quickfix" })
vim.keymap.set("n", "<leader>qa", function()
	local current_line = vim.fn.line(".")
	local current_file = vim.fn.expand("%:p")
	local line_content = vim.fn.getline(".")

	local qf_entry = {
		filename = current_file,
		lnum = current_line,
		text = line_content,
	}

	vim.fn.setqflist({ qf_entry }, "a")
	print("Added line to quickfix list")
end, { desc = "Add current line to quickfix" })

vim.keymap.set("n", "<leader>qd", function()
	local qflist = vim.fn.getqflist()
	if #qflist == 0 then
		print("Quickfix list is empty")
		return
	end

	local current_idx = vim.fn.getqflist({ idx = 0 }).idx
	if current_idx > 0 then
		table.remove(qflist, current_idx)
		vim.fn.setqflist(qflist, "r")
		print(string.format("Removed entry %d from quickfix list", current_idx))
	end
end, { desc = "Delete current quickfix entry" })
vim.keymap.set("n", "<leader>qn", ":cnewer<CR>", { desc = "Next quickfix history" })
vim.keymap.set("n", "<leader>qo", ":colder<CR>", { desc = "Older quickfix history" })
vim.keymap.set("n", "<leader>qh", ":chistory<CR>", { desc = "Show quickfix history" })

-- Spelling
vim.keymap.set("n", "<leader>vS", ":set spell!<CR>", { desc = "View Spellcheck" })
vim.keymap.set("n", "<leader>vs", "z=", { desc = "View Spellcheck Suggestions" })

local function ToggleScratch()
	local scratch_win_id = nil
	for _, win_id in ipairs(vim.api.nvim_list_wins()) do
		local buf_id = vim.api.nvim_win_get_buf(win_id)
		if vim.bo[buf_id].filetype == "scratch" then
			scratch_win_id = win_id
			break
		end
	end

	if scratch_win_id ~= nil then
		vim.api.nvim_win_close(scratch_win_id, true)
		return
	end

	local buf_id
	for _, id in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[id].filetype == "scratch" then
			buf_id = id
		end
	end
	if buf_id == nil then
		buf_id = vim.api.nvim_create_buf(true, true)
		vim.bo[buf_id].filetype = "scratch"
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win_id = vim.api.nvim_open_win(buf_id, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		border = "rounded",
		style = "minimal",
	})

	vim.wo[win_id].number = true
	vim.wo[win_id].relativenumber = true
end
vim.keymap.set("n", "<leader>vp", ToggleScratch, { desc = "Toggle scratch buffer" })

vim.keymap.set("n", "<leader>gg", function()
	local in_tmux = vim.fn.system('[ -n "$TMUX" ] && echo 1 || echo 0'):gsub("%s+", "")

	if in_tmux == "1" then
		local has_lazygit = vim.fn.system("tmux list-windows | grep -q lazygit && echo 1 || echo 0"):gsub("%s+", "")

		if has_lazygit == "1" then
			vim.fn.system("tmux select-window -t lazygit")
		else
			vim.fn.system("tmux new-window -n lazygit 'lg'")
		end
	else
		vim.notify("Not running in tmux session", vim.log.levels.WARN)
	end
end, { desc = "Open lazygit in tmux window" })

function OpenInGithub(commit_hash, use_branch)
	commit_hash = commit_hash or ""
	use_branch = use_branch or false

	local file_dir = vim.fn.expand("%:h")
	local file_path = vim.fn
		.system("cd " .. file_dir .. "; git ls-files --full-name " .. vim.fn.shellescape(vim.fn.expand("%:t")))
		:gsub("%s+$", "")

	local branch
	if use_branch then
		branch = vim.fn.system("git symbolic-ref --short -q HEAD"):gsub("%s+$", "")
	else
		branch = "master"
	end

	local git_remote = vim.fn.system("cd " .. file_dir .. "; git remote get-url origin"):gsub("%s+$", "")
	local base_url, repo_path

	if git_remote:match("^https://") then
		base_url = git_remote:match("^(https://[^/]+)")
		repo_path = git_remote:match("/([^/]+/[^/]+)/?$"):gsub("%.git$", "")
	else
		base_url = "https://" .. git_remote:match("@([^:]+)")
		repo_path = git_remote:match(":(.*)"):gsub("%.git$", "")
	end

	local url = base_url .. "/" .. repo_path

	if commit_hash ~= "" then
		url = url .. "/commit/" .. commit_hash
	else
		url = url .. "/blob/" .. branch .. "/" .. file_path
	end

	local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
	vim.fn.system(open_cmd .. " " .. vim.fn.shellescape(url))
end

vim.keymap.set("n", "<leader>gof", function()
	OpenInGithub()
end, { desc = "Git open file in GitHub" })

vim.keymap.set("n", "<leader>goc", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd("q")
	OpenInGithub(word)
end, { desc = "Git open commit in GitHub" })

vim.keymap.set("n", "<leader>gob", function()
	OpenInGithub("", true)
end, { desc = "Git open branch in GitHub" })
