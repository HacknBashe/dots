local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("SauceCodePro Nerd Font Mono", { weight = "Light" })
config.font_size = 20
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

config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

local myTheme = wezterm.color.get_builtin_schemes()["tokyonight"]
myTheme.background = "#1a1b26"
-- myTheme.indexed = { [16] = "#ff966c", [17] = "#c53b53" }

config.color_schemes = {
	["My Theme"] = myTheme,
}
config.color_scheme = "My Theme"
config.window_background_opacity = 0.85

return config
