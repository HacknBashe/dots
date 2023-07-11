local wezterm = require("wezterm")

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.font = wezterm.font("SauceCodePro Nerd Font Mono", { weight = "Light" })
config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font("SauceCodePro Nerd Font Mono", {
			weight = "Regular",
		}),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font("SauceCodePro Nerd Font Mono", {
			weight = "Regular",
			italic = true,
		}),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font("SauceCodePro Nerd Font Mono", {
			weight = "Regular",
			italic = true,
		}),
	},

	{
		intensity = "Half",
		italic = true,
		font = wezterm.font("SauceCodePro Nerd Font Mono", {
			weight = "ExtraLight",
			italic = true,
		}),
	},
	{
		intensity = "Half",
		italic = false,
		font = wezterm.font("SauceCodePro Nerd Font Mono", {
			weight = "ExtraLight",
		}),
	},
}

config.font_size = 24

config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

local nordfox = wezterm.color.get_builtin_schemes()["nordfox"]
nordfox.background = "#1c2028"

config.color_schemes = {
	["My Nordfox"] = nordfox,
}
config.color_scheme = "My Nordfox"
config.window_background_opacity = 0.92

config.keys = {
	{
		key = "t",
		mods = "ALT",
		action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES|TABS" }),
	},
}

wezterm.on("update-right-status", function(window, pane)
	local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")

	-- Make it italic and underlined
	window:set_right_status(wezterm.format({
		{ Attribute = { Underline = "Single" } },
		{ Attribute = { Italic = true } },
		{ Text = "Hello " .. date },
	}))
end)

config.enable_kitty_graphics = true

return config
