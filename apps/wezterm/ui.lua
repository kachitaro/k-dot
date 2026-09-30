local wezterm = require 'wezterm'
local module = {}

local function get_theme_path()
  local candidates = {}

  -- 1. Check DOTFILES_DIR environment variable
  local dotfiles_dir = os.getenv("DOTFILES_DIR")
  if dotfiles_dir and dotfiles_dir ~= "" then
    table.insert(candidates, dotfiles_dir .. "/themes/generated/theme.lua")
  end

  -- 2. Resolve via wezterm.config_dir
  if wezterm.config_dir then
    table.insert(candidates, wezterm.config_dir .. "/../themes/generated/theme.lua")
    table.insert(candidates, wezterm.config_dir .. "/themes/generated/theme.lua")
  end

  -- 3. Resolve via wezterm.config_file (if available)
  if wezterm.config_file then
    local config_dir = wezterm.config_file:match("^(.*)[/\\]")
    if config_dir then
      table.insert(candidates, config_dir .. "/../themes/generated/theme.lua")
    end
  end

  -- 4. Fallback paths (home directory)
  local home = os.getenv("HOME") or os.getenv("USERPROFILE") or (wezterm.home_dir or "")
  if home ~= "" then
    table.insert(candidates, home .. "/.dotfiles/themes/generated/theme.lua")
    table.insert(candidates, home .. "/.config/themes/generated/theme.lua")
  end

  for _, path in ipairs(candidates) do
    local f = io.open(path, "r")
    if f then
      f:close()
      return path
    end
  end

  -- 5. Fallback: Resolve dynamically via `dot theme path` (or `k-dot theme path`)
  local ok, dynamic_path = pcall(function()
    local success, out, _ = wezterm.run_child_process({ "dot", "theme", "path" })
    if success and out and out ~= "" then
      return out:gsub("[\r\n]+$", "") .. "/theme.lua"
    end
    local k_success, k_out, _ = wezterm.run_child_process({ "k-dot", "theme", "path" })
    if k_success and k_out and k_out ~= "" then
      return k_out:gsub("[\r\n]+$", "") .. "/theme.lua"
    end
    return nil
  end)

  if ok and dynamic_path then
    local f = io.open(dynamic_path, "r")
    if f then
      f:close()
      return dynamic_path
    end
  end

  if wezterm.config_dir then
    return wezterm.config_dir .. "/../themes/generated/theme.lua"
  end
  return (home ~= "" and (home .. "/.dotfiles/themes/generated/theme.lua")) or "themes/generated/theme.lua"
end


function module.setup(config)
  config.tab_bar_at_bottom = true
  config.status_update_interval = 100
  config.use_fancy_tab_bar = false
  -- config.hide_tab_bar_if_only_one_tab = true
  config.scrollback_lines = 10000
  config.adjust_window_size_when_changing_font_size = false
  -- Load dynamically generated theme
  local theme_path = get_theme_path()
  local success, theme = pcall(dofile, theme_path)

  if success and type(theme) == "table" then
    config.colors = {
      background = theme.bg,
      foreground = theme.fg,
      ansi = { theme.black, theme.red, theme.green, theme.yellow, theme.blue, theme.magenta, theme.cyan, theme.white },
      brights = { theme.black, theme.red, theme.green, theme.yellow, theme.blue, theme.magenta, theme.cyan, theme.white },
      tab_bar = {
      background = 'rgba(0, 0, 0, 0)',
      active_tab = {
        bg_color = 'rgba(43, 32, 66, 0.8)',
        fg_color = '#c0c0c0',
      },
      inactive_tab = {
        bg_color = 'rgba(0, 0, 0, 0)',
        fg_color = '#808080',
      },
      inactive_tab_hover = {
        bg_color = 'rgba(59, 48, 82, 0.5)',
        fg_color = '#909090',
        italic = true,
      },
      new_tab = {
        bg_color = 'rgba(0, 0, 0, 0)',
        fg_color = '#808080',
      },
      new_tab_hover = {
        bg_color = 'rgba(59, 48, 82, 0.5)',
        fg_color = '#909090',
        italic = true,
      },
    },
  }
  end
end

return module