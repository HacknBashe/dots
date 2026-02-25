-- Logo shadow marker system for mini.starter (inspired by OpenCode)
--
-- Markers in header string:
-- _ = space with shadow bg (letter body fill)
-- ^ = ▀ with letter fg + shadow bg (half-block transition)
-- ~ = ▀ with shadow fg only (dimmed half-block)
-- | = separator between neo (darker) and vim (lighter) tones

local M = {}

M.header = [[
█▀▀▄ █▀▀█ █▀▀█| █  █ █ █▀▄▀▄
█__█ █^^^ █__█| █__█ █ █_^_█
▀~~▀ ▀▀▀▀ ▀▀▀▀|  ▀▀  ▀ ▀~~~▀]]

local function tint(bg_color, fg_color, factor)
	local bg_r = math.floor(bg_color / 65536)
	local bg_g = math.floor(bg_color / 256) % 256
	local bg_b = bg_color % 256
	local fg_r = math.floor(fg_color / 65536)
	local fg_g = math.floor(fg_color / 256) % 256
	local fg_b = fg_color % 256
	local r = math.floor(bg_r + (fg_r - bg_r) * factor)
	local g = math.floor(bg_g + (fg_g - bg_g) * factor)
	local b = math.floor(bg_b + (fg_b - bg_b) * factor)
	return r * 65536 + g * 256 + b
end

function M.setup_hl()
	local header_hl = vim.api.nvim_get_hl(0, { name = "MiniStarterHeader", link = false })
	if not header_hl.fg then
		header_hl = vim.api.nvim_get_hl(0, { name = "Title", link = false })
	end
	local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local fg = header_hl.fg or 0x82aaff
	local bg = normal_hl.bg or 0x1a1b26

	local neo_fg = tint(bg, fg, 0.75)
	local vim_fg = tint(fg, 0xffffff, 0.2)

	local neo_shadow = tint(bg, neo_fg, 0.25)
	local vim_shadow = tint(bg, vim_fg, 0.25)

	vim.api.nvim_set_hl(0, "StarterNeo", { fg = neo_fg })
	vim.api.nvim_set_hl(0, "StarterNeoShadow", { bg = neo_shadow })
	vim.api.nvim_set_hl(0, "StarterNeoHalf", { fg = neo_fg, bg = neo_shadow })
	vim.api.nvim_set_hl(0, "StarterNeoDim", { fg = neo_shadow })

	vim.api.nvim_set_hl(0, "StarterVim", { fg = vim_fg })
	vim.api.nvim_set_hl(0, "StarterVimShadow", { bg = vim_shadow })
	vim.api.nvim_set_hl(0, "StarterVimHalf", { fg = vim_fg, bg = vim_shadow })
	vim.api.nvim_set_hl(0, "StarterVimDim", { fg = vim_shadow })

	vim.api.nvim_set_hl(0, "MiniStarterFooter", { fg = fg, italic = false })
end

function M.footer_right(content)
	local win = vim.fn.win_findbuf(vim.api.nvim_get_current_buf())[1] or 0
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)
	local coords = require("mini.starter").content_coords(content, "footer")
	if #coords > 0 then
		local first = coords[1].line
		local pad_v = math.max(0, height - #content)
		for _ = 1, pad_v do
			table.insert(content, first, { { string = "", type = "empty" } })
		end
		for _, c in ipairs(require("mini.starter").content_coords(content, "footer")) do
			local text = content[c.line][c.unit].string
			local pad_h = width - vim.fn.strdisplaywidth(text) - 1
			content[c.line] = { { string = string.rep(" ", math.max(0, pad_h)) .. text, type = "footer", hl = "MiniStarterFooter" } }
		end
	end
	return content
end

function M.hook(content)
	local starter = require("mini.starter")
	local coords = starter.content_coords(content, "header")
	for i = #coords, 1, -1 do
		local c = coords[i]
		local unit = content[c.line][c.unit]
		local chars = vim.fn.split(unit.string, "\\zs")
		local new_units = {}
		local vim_mode = false
		for _, ch in ipairs(chars) do
			if ch == "|" then
				vim_mode = true
			elseif ch == "_" then
				local hl = vim_mode and "StarterVimShadow" or "StarterNeoShadow"
				table.insert(new_units, { string = " ", type = "header", hl = hl })
			elseif ch == "^" then
				local hl = vim_mode and "StarterVimHalf" or "StarterNeoHalf"
				table.insert(new_units, { string = "▀", type = "header", hl = hl })
			elseif ch == "~" then
				local hl = vim_mode and "StarterVimDim" or "StarterNeoDim"
				table.insert(new_units, { string = "▀", type = "header", hl = hl })
			else
				local hl = vim_mode and "StarterVim" or "StarterNeo"
				table.insert(new_units, { string = ch, type = "header", hl = hl })
			end
		end
		table.remove(content[c.line], c.unit)
		for j, u in ipairs(new_units) do
			table.insert(content[c.line], c.unit + j - 1, u)
		end
	end
	return content
end

return M
