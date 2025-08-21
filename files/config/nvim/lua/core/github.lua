function OpenInGithub(commit_hash, use_branch, line_number, end_line_number)
	commit_hash = commit_hash or ""
	use_branch = use_branch or false
	line_number = line_number or nil
	end_line_number = end_line_number or nil

	local repo_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+$", "")

	if repo_root == "" or repo_root:match("^fatal:") then
		vim.notify("Not in a git repository", vim.log.levels.ERROR)
		return
	end

	local absolute_path = vim.fn.expand("%:p")
	local file_path = absolute_path:gsub("^" .. vim.pesc(repo_root .. "/"), "")

	local branch
	if use_branch then
		branch = vim.fn.system("cd " .. repo_root .. "; git symbolic-ref --short -q HEAD"):gsub("%s+$", "")
	else
		branch = "master"
	end

	local git_remote = vim.fn.system("cd " .. repo_root .. "; git remote get-url origin"):gsub("%s+$", "")
	local base_url, repo_path

	if git_remote:match("^https://") then
		base_url = git_remote:match("^(https://[^/]+)")
		local repo_match = git_remote:match("/([^/]+/[^/]+)/?$")
		if repo_match then
			repo_path = repo_match:gsub("%.git$", "")
		else
			vim.notify("Failed to parse HTTPS repository path", vim.log.levels.ERROR)
			return
		end
	else
		local host, path = git_remote:match("git@([^:]+):(.*)")
		if host and path then
			base_url = "https://" .. host
			repo_path = path:gsub("%.git$", "")
		else
			vim.notify("Failed to parse SSH repository URL", vim.log.levels.ERROR)
			return
		end
	end

	local url = base_url .. "/" .. repo_path

	if commit_hash ~= "" then
		url = url .. "/commit/" .. commit_hash
	else
		if file_path ~= "" then
			url = url .. "/blob/" .. branch .. "/" .. file_path
			if line_number then
				if end_line_number and end_line_number ~= line_number then
					url = url .. "#L" .. line_number .. "-L" .. end_line_number
				else
					url = url .. "#L" .. line_number
				end
			end
		else
			url = url .. "/tree/" .. branch
		end
	end

	local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
	vim.fn.system(open_cmd .. " " .. vim.fn.shellescape(url))
end

vim.keymap.set("n", "<leader>gof", function()
	OpenInGithub()
end, { desc = "Git open file in GitHub (default branch)" })

-- Open file on current branch
vim.keymap.set("n", "<leader>gOf", function()
	OpenInGithub("", true)
end, { desc = "Git open file in GitHub (current branch)" })

vim.keymap.set("n", "<leader>goc", function()
	local word = vim.fn.expand("<cword>")
	OpenInGithub(word)
end, { desc = "Git open commit in GitHub" })

-- Open commit or file on current branch when commit not under cursor
vim.keymap.set("n", "<leader>gOc", function()
	local word = vim.fn.expand("<cword>")
	if word ~= nil and word ~= "" then
		OpenInGithub(word)
	else
		OpenInGithub("", true)
	end
end, { desc = "Git open commit/file in GitHub (current branch)" })


vim.keymap.set("n", "<leader>gol", function()
	local current_line = vim.fn.line(".")
	OpenInGithub("", false, current_line)
end, { desc = "Git open line in GitHub (default branch)" })

-- Open current line on current branch
vim.keymap.set("n", "<leader>gOl", function()
	local current_line = vim.fn.line(".")
	OpenInGithub("", true, current_line)
end, { desc = "Git open line in GitHub (current branch)" })

vim.keymap.set("v", "<leader>gol", function()
	vim.cmd('normal! \27')
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	OpenInGithub("", false, start_line, end_line)
end, { desc = "Git open line range in GitHub (default branch)" })

-- Open selected line range on current branch
vim.keymap.set("v", "<leader>gOl", function()
	vim.cmd('normal! \27')
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	OpenInGithub("", true, start_line, end_line)
end, { desc = "Git open line range in GitHub (current branch)" })
