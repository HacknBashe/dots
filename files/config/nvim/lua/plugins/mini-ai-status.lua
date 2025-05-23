local spinner_active = false
local spinner_frames = { "⠋", "⠙", "⠸", "⠸", "⢰", "⣠", "⣄", "⡆", "⠇" }
local spinner_index = 1
local timer = nil

-- Reset spinner when request finishes
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestFinished",
  callback = function()
    spinner_active = false
    if timer then
      timer:stop()
      timer = nil
    end
    -- Force statusline refresh
    vim.cmd("redrawstatus")
  end,
})

-- Start spinner when request begins
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestStarted",
  callback = function()
    spinner_active = true

    -- Create timer for spinner animation
    if timer then
      timer:stop()
    end

    timer = vim.loop.new_timer()
    timer:start(
      0,
      100,
      vim.schedule_wrap(function()
        -- Update spinner frame
        spinner_index = (spinner_index % #spinner_frames) + 1
        -- Force statusline refresh
        vim.cmd("redrawstatus")
      end)
    )
  end,
})

-- Main function returned when module is required
return function()
  if spinner_active then
    return spinner_frames[spinner_index] .. " 󱙺"
  else
    return "󱙺" -- or whatever icon you prefer
  end
end
