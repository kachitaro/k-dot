local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require('core').setup(config)
require('ui').setup(config)
require('status').setup()

return config