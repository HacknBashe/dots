local notes_dir = vim.fn.expand("~/notes")
local daily_format = "%Y-%m-%d"

-- Helper: convert string to kebab-case
local function to_kebab(str)
	return str:lower():gsub("%s+", "-"):gsub("[^a-z0-9-]", "")
end

-- Helper: check if file has frontmatter
local function has_frontmatter(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)
	return #lines > 0 and lines[1] == "---"
end

-- Helper: add frontmatter to buffer
local function add_frontmatter(bufnr, id, tags)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	tags = tags or {}
	
	local frontmatter = { "---", 'id: "' .. id .. '"' }
	
	if #tags > 0 then
		table.insert(frontmatter, "tags:")
		for _, tag in ipairs(tags) do
			table.insert(frontmatter, "  - " .. tag)
		end
	else
		table.insert(frontmatter, "tags: []")
	end
	
	table.insert(frontmatter, "---")
	table.insert(frontmatter, "")
	
	-- Get existing content
	local existing = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	
	-- Prepend frontmatter
	for i = #frontmatter, 1, -1 do
		table.insert(existing, 1, frontmatter[i])
	end
	
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, existing)
end

-- Helper: open/create a note file
local function open_note(filename)
	local path = notes_dir .. "/" .. filename
	
	-- Check if file is already open in a buffer
	local bufnr = vim.fn.bufnr(path)
	if bufnr ~= -1 then
		-- Buffer exists, just switch to it
		vim.api.nvim_set_current_buf(bufnr)
	else
		-- Buffer doesn't exist, edit it
		vim.cmd("edit " .. path)
	end
end

-- Daily note with offset (0=today, 1=tomorrow, -1=yesterday)
local function open_daily(offset)
	local date = os.date(daily_format, os.time() + (offset * 86400))
	local filename = date .. ".md"
	open_note(filename)
	vim.defer_fn(function()
		vim.cmd("filetype detect")
	end, 50)
end

-- New note: prompt for title, create kebab-case file
local function create_note()
	vim.ui.input({ prompt = "Note title: " }, function(title)
		if title and title ~= "" then
			local filename = to_kebab(title) .. ".md"
			open_note(filename)
		end
	end)
end

-- Visual selection → markdown link + create target file
local function link_selection()
	-- Save current register
	local save_reg = vim.fn.getreg('"')
	local save_regtype = vim.fn.getregtype('"')

	-- Yank visual selection
	vim.cmd('normal! "zy')
	local text = vim.fn.getreg("z")

	-- Restore register
	vim.fn.setreg('"', save_reg, save_regtype)

	if text and text ~= "" then
		local filename = to_kebab(text) .. ".md"
		local link = "[" .. text .. "](./" .. filename .. ")"

		-- Replace visual selection with link
		vim.cmd('normal! gv"_c' .. link)
		vim.cmd("normal! `<")

		-- Create empty target file if it doesn't exist (autocmd will add frontmatter)
		local filepath = notes_dir .. "/" .. filename
		if vim.fn.filereadable(filepath) == 0 then
			vim.fn.writefile({}, filepath)
		end
	end
end

-- Insert link: prompt for text, insert link at cursor + create target file
local function insert_link()
	vim.ui.input({ prompt = "Link text: " }, function(text)
		if text and text ~= "" then
			local filename = to_kebab(text) .. ".md"
			local link = "[" .. text .. "](./" .. filename .. ")"

			-- Insert link at cursor
			vim.api.nvim_put({ link }, "c", true, true)

			-- Create empty target file if it doesn't exist (autocmd will add frontmatter)
			local filepath = notes_dir .. "/" .. filename
			if vim.fn.filereadable(filepath) == 0 then
				vim.fn.writefile({}, filepath)
			end
		end
	end)
end

-- Toggle checkbox: [ ] → [x] → [-] → [ ]
local function toggle_checkbox()
	local line = vim.api.nvim_get_current_line()
	local new_line = line

	if line:match("^%s*- %[ %]") then
		new_line = line:gsub("^(%s*- )%[ %]", "%1[x]")
	elseif line:match("^%s*- %[x%]") then
		new_line = line:gsub("^(%s*- )%[x%]", "%1[-]")
	elseif line:match("^%s*- %[-%]") then
		new_line = line:gsub("^(%s*- )%[-%]", "%1[ ]")
	elseif line:match("^%s*-") then
		new_line = line:gsub("^(%s*-)", "%1 [ ]")
	end

	if new_line ~= line then
		vim.api.nvim_set_current_line(new_line)
	end
end

-- Keymaps
vim.keymap.set("n", "<leader>nt", function()
	open_daily(0)
end, { desc = "Today's note" })

vim.keymap.set("n", "<leader>nT", function()
	open_daily(1)
end, { desc = "Tomorrow's note" })

vim.keymap.set("n", "<leader>ny", function()
	open_daily(-1)
end, { desc = "Yesterday's note" })

vim.keymap.set("n", "<leader>nn", create_note, { desc = "New note" })

vim.keymap.set("n", "<leader>nl", insert_link, { desc = "Insert link" })

vim.keymap.set("v", "<leader>nl", link_selection, { desc = "Create link from selection" })

-- Markdown-specific: checkbox toggle on Enter
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.keymap.set("n", "<CR>", toggle_checkbox, { buffer = true, desc = "Toggle checkbox" })
	end,
})

-- Auto-add frontmatter to markdown files in notes directory (SINGLE SOURCE OF TRUTH)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
	pattern = notes_dir .. "/*.md",
	callback = function(ev)
		-- Wait a bit for buffer to be fully loaded
		vim.defer_fn(function()
			-- Only add if buffer is valid and has no frontmatter
			if not vim.api.nvim_buf_is_valid(ev.buf) or has_frontmatter(ev.buf) then
				return
			end
			
			-- Get filename without extension as id
			local filename = vim.fn.expand("%:t:r")
			local tags = {}
			
			-- If filename matches YYYY-MM-DD pattern, it's a daily note
			if filename:match("^%d%d%d%d%-%d%d%-%d%d$") then
				tags = { "daily-notes" }
			end
			
			add_frontmatter(ev.buf, filename, tags)
		end, 100)
	end,
})

-- Markdown folding by header level
function MarkdownLevel()
	local line = vim.fn.getline(vim.v.lnum)
	if string.match(line, "^# .*$") then
		return ">1"
	elseif string.match(line, "^## .*$") then
		return ">2"
	elseif string.match(line, "^### .*$") then
		return ">3"
	elseif string.match(line, "^#### .*$") then
		return ">4"
	elseif string.match(line, "^##### .*$") then
		return ">5"
	elseif string.match(line, "^###### .*$") then
		return ">6"
	else
		return "="
	end
end

vim.api.nvim_command("autocmd BufEnter *.md setlocal foldexpr=v:lua.MarkdownLevel()")
vim.api.nvim_command("autocmd BufEnter *.md setlocal foldmethod=expr")
