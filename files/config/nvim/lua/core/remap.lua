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
