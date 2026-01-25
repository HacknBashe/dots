local M = {}

-- Check if executable exists and notify if missing
-- Returns: true if available, false if missing (and shows notification)
function M.check_executable(name, plugin_name)
	if vim.fn.executable(name) == 1 then
		return true
	end

	-- Defer notification until after mini.notify is loaded
	vim.schedule(function()
		vim.notify(
			string.format("Missing dependency '%s' for %s", name, plugin_name),
			vim.log.levels.INFO
		)
	end)
	return false
end

-- Check multiple executables (all must be present)
-- Returns: true if all available, false if any missing (shows notification for first missing)
function M.check_executables(deps, plugin_name)
	for _, dep in ipairs(deps) do
		if not M.check_executable(dep, plugin_name) then
			return false
		end
	end
	return true
end

return M
