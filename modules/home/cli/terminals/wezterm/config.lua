local wezterm = require("wezterm")
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local config = wezterm.config_builder()
local act = wezterm.action

-- Session
local sessionizer_schema = {
	sessionizer.DefaultWorkspace({ label_overwrite = "  Default" }),
	{
		sessionizer.AllActiveWorkspaces({}),
		processing = sessionizer.for_each_entry(function(entry)
			entry.label = " " .. entry.label:gsub(wezterm.home_dir .. "/Projects/", "")
		end),
	},
	{
		sessionizer.FdSearch({
			wezterm.home_dir .. "/Projects",
			max_depth = 32,
			include_submodules = true,
		}),
		processing = sessionizer.for_each_entry(function(entry)
			entry.label = " " .. entry.label:gsub(wezterm.home_dir .. "/Projects/", "")
		end),
	},
}

config.default_prog = { "fish", "-l" }
config.front_end = "WebGpu"

-- Appearance
config.font_size = 13
-- defined by stylix
-- config.color_scheme = "Catppuccin Mocha"
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false
config.tab_max_width = 25
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
-- config.command_palette_font_size = 16

-- see https://wezterm.org/config/appearance.html#native-fancy-tab-bar-appearance
config.window_frame = {
	font = wezterm.font({ family = "Inter", weight = "Bold" }),
	font_size = 13,
	active_titlebar_bg = "#1e1e2e",
	inactive_titlebar_bg = "#1e1e2e",
}

config.colors = {
	tab_bar = {
		inactive_tab_edge = "#1e1e2e",
		active_tab = { bg_color = "#000000", fg_color = "#c0c0c0" },
		inactive_tab = { bg_color = "#181825", fg_color = "#808080" },
		inactive_tab_hover = { bg_color = "#313244", fg_color = "#909090" },
		new_tab = { bg_color = "#1e1e2e", fg_color = "#808080" },
		new_tab_hover = { bg_color = "#313244", fg_color = "#909090" },
	},
}

-- Domains
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }

-- Keybindings
config.disable_default_key_bindings = true
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{ key = "L", mods = "LEADER|SHIFT", action = act.ShowDebugOverlay },
	{ key = "s", mods = "LEADER", action = sessionizer.show(sessionizer_schema) },
	{ key = "d", mods = "LEADER", action = act.DetachDomain("CurrentPaneDomain") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ShowLauncher },
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "n", mods = "LEADER", action = act.SpawnWindow },
	{ key = "w", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },
	-- https://wezterm.org/config/lua/keyassignment/CharSelect.html
	{
		key = "u",
		mods = "LEADER",
		action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
	},
	{ key = "phys:Space", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "phys:Space", mods = "LEADER|CTRL", action = act.QuickSelect },

	{ key = "phys:Space", mods = "ALT", action = act.ActivateCommandPalette },
	{ key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },

	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	{ key = "C", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
	{ key = "V", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
	{ key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
	{ key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },

	-- https://wezterm.org/scrollback.html
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
	{ key = "K", mods = "SHIFT|CTRL", action = act.ClearScrollback("ScrollbackOnly") },
}

-- Smart Splits
smart_splits.apply_to_config(config, {
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
	modifiers = {
		move = "CTRL",
		resize = "CTRL",
	},
	log_level = "warn",
})

return config
