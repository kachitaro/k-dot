local wezterm = require 'wezterm'
local act = wezterm.action
local module = {}

function module.setup(config)
  local is_windows = wezterm.target_triple:find("windows") ~= nil

  if is_windows then
    local raw_home = wezterm.home_dir or os.getenv("USERPROFILE") or ""
    local home = (raw_home:gsub("\\", "/"))
    local dotfiles_dir = os.getenv("DOTFILES_DIR") or (home .. "/.dotfiles")

    -- Resolve user_profile.ps1
    local candidates = {
      dotfiles_dir .. "/apps/powershell/user_profile.ps1",
      home .. "/.dotfiles/apps/powershell/user_profile.ps1",
      home .. "/.config/powershell/user_profile.ps1",
    }
    local ps_profile = nil
    for _, path in ipairs(candidates) do
      local f = io.open(path, "r")
      if f then
        f:close()
        ps_profile = path:gsub("/", "\\")
        break
      end
    end

    -- Determine shell executable (prefer pwsh.exe, fallback to powershell.exe)
    local pwsh_cmd = "pwsh.exe"
    local ok, _ = pcall(function()
      local success, _, _ = wezterm.run_child_process({ "pwsh.exe", "-v" })
      if not success then
        pwsh_cmd = "powershell.exe"
      end
    end)
    if not ok then
      pwsh_cmd = "powershell.exe"
    end

    if ps_profile then
      config.default_prog = {
        pwsh_cmd,
        '-NoExit',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        ps_profile,
      }
    else
      config.default_prog = {
        pwsh_cmd,
        '-NoExit',
        '-ExecutionPolicy',
        'Bypass',
      }
    end
  end

  config.font = wezterm.font('JetBrainsMono Nerd Font Mono', {
    weight = 'Regular',
    style  = 'Normal',
  })
  config.font_size = 10.5
  config.font_rules = {
    {
      italic = true,
      font = wezterm.font {
        family = "JetBrainsMono Nerd Font Mono",
        weight = "Regular",
        italic = true,
      },
    },
    {
      intensity = "Bold",
      font = wezterm.font {
        family = "JetBrainsMono Nerd Font Mono",
        weight = "Bold",
      },
    },
  }

  config.window_decorations = "RESIZE"
  config.default_cursor_style = 'BlinkingBar'
  config.automatically_reload_config = true

  config.color_scheme = 'catppuccin-frappe'
  config.colors = {
    compose_cursor = '#303446'
  }

  config.keys = {
    {
      key = '|',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'd',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    }
  }
end

return module