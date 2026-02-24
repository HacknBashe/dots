-- Logo shadow marker system for mini.starter (inspired by OpenCode)
--
-- Markers in header string:
-- _ = space with shadow bg (letter body fill)
-- ^ = ▀ with letter fg + shadow bg (half-block transition)
-- ~ = ▀ with shadow fg only (dimmed half-block)

local M = {}

M.header = string.format([[
█▀▀▄ █▀▀█ █▀▀█ █  █ █ █▀▄▀▄
█__█ █^^^ █__█ █__█ █ █_^_█
▀~~▀ ▀▀▀▀ ▀▀▀▀  ▀▀  ▀ ▀~~~▀
                    v%d.%d.%d]], vim.version().major, vim.version().minor, vim.version().patch)

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
	local shadow = tint(bg, fg, 0.25)
	vim.api.nvim_set_hl(0, "StarterShadow", { bg = shadow })
	vim.api.nvim_set_hl(0, "StarterHalf", { fg = fg, bg = shadow })
	vim.api.nvim_set_hl(0, "StarterDim", { fg = shadow })
end

function M.hook(content)
	local starter = require("mini.starter")
	local coords = starter.content_coords(content, "header")
	for i = #coords, 1, -1 do
		local c = coords[i]
		local unit = content[c.line][c.unit]
		local chars = vim.fn.split(unit.string, "\\zs")
		local new_units = {}
		for _, ch in ipairs(chars) do
			if ch == "_" then
				table.insert(new_units, { string = " ", type = "header", hl = "StarterShadow" })
			elseif ch == "^" then
				table.insert(new_units, { string = "▀", type = "header", hl = "StarterHalf" })
			elseif ch == "~" then
				table.insert(new_units, { string = "▀", type = "header", hl = "StarterDim" })
			else
				table.insert(new_units, { string = ch, type = "header", hl = "MiniStarterHeader" })
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
