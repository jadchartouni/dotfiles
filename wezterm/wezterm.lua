-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- Leader key
config.leader = {
    key = 'a',
    mods = 'CMD',
    timeout_milliseconds = 1000,
}

-- Other keys
config.keys = {
    -- Vertical split
    {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.SplitHorizontal {
            domain = 'CurrentPaneDomain',
        },
    },

    -- Horizontal split
    {
        key = '-',
        mods = 'LEADER',
        action = wezterm.action.SplitVertical {
            domain = 'CurrentPaneDomain',
        },
    },

    -- Move between panes
    {
        key = 'h',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection 'Down',
    },

    -- New tab
    {
        key = 'c',
        mods = 'LEADER',
        action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },

    -- Close pane
    {
        key = 'x',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentPane {
            confirm = true,
        },
    },

    -- Zoom pane
    {
        key = 'z',
        mods = 'LEADER',
        action = wezterm.action.TogglePaneZoomState,
    },

    {
        key="Enter",
        mods="SHIFT",
        action=wezterm.action{SendString="\x1b\r"}},
}

-- JetBrainsMono Nerd Font (regular). 'Never' keeps wide icon glyphs from
-- spilling outside their cell (e.g. in nvim-tree).
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.allow_square_glyphs_to_overflow_width = 'Never'

-- or, changing the font size and color scheme.
config.font_size = 16
config.color_scheme = 'SentryCore'

-- Window opacity
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20

-- Finally, return the configuration to wezterm:
return config
