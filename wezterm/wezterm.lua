-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- or, changing the font size and color scheme.
config.font_size = 12
config.color_scheme = 'Night Owl (Gogh)'

-- Finally, return the configuration to wezterm:
return config
