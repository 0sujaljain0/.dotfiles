local wezterm = require("wezterm")
--local config = wezterm.config_builder()
local config = {}
config.colors = {}

config.default_prog = { '/bin/zsh', '-1' }

wezterm.on("gui-startup", function (cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}



--config.color_scheme = "Batman"
config.colors.background = "#1A1A1A"
config.font = wezterm.font("JetBrains Mono", {})
config.font_size = 14.0
config.use_fancy_tab_bar = false
config.freetype_load_target = "HorizontalLcd"
config.hide_tab_bar_if_only_one_tab = true
--config.window_background_opacity = 0.95

return config
