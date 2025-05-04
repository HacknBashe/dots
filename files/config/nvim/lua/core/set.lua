local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", {})

-- Highlight text on yank
autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

function PositionHelp()
	vim.cmd("wincmd L")
	vim.api.nvim_win_set_width(0, 80)
end

autocmd("BufEnter", {
	group = yank_group,
	pattern = "",
	callback = function()
		if vim.bo.buftype == "help" then
			vim.defer_fn(PositionHelp, 1)
		end
	end,
})

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

vim.opt.colorcolumn = "120"

vim.opt.signcolumn = "yes"

vim.opt.foldmethod = "expr"
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

local function setup_file_check_timer()
	if _G.file_check_timer then
		_G.file_check_timer:stop()
		_G.file_check_timer:close()
	end

	_G.last_mtimes = _G.last_mtimes or {}
	_G.file_check_timer = vim.loop.new_timer()

	_G.file_check_timer:start(
		1000,
		1000,
		vim.schedule_wrap(function()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) then
					local path = vim.api.nvim_buf_get_name(buf)
					if path ~= "" then
						local stat = vim.loop.fs_stat(path)
						if stat then
							if _G.last_mtimes[buf] and stat.mtime.sec > _G.last_mtimes[buf] then
								vim.cmd("checktime " .. buf)
								vim.notify("File updated: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
							end

							_G.last_mtimes[buf] = stat.mtime.sec
						end
					end
				end
			end
		end)
	)
end

setup_file_check_timer()

autocmd("BufDelete", {
	pattern = "*",
	callback = function(args)
		if _G.last_mtimes and _G.last_mtimes[args.buf] then
			_G.last_mtimes[args.buf] = nil
		end
	end,
})

vim.api.nvim_create_user_command("RestartFileWatcher", setup_file_check_timer, {})
