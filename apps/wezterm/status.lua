local wezterm = require 'wezterm'
local module = {}

-- Cấu hình màu sắc theo phần trăm sử dụng (Dracula theme style)
local function usage_color(usage)
  local pct = tonumber(usage)
  if not pct then return '#888888' end
  if pct >= 90 then return '#ff5555' end
  if pct >= 80 then return '#ffb86c' end
  if pct >= 60 then return '#f1fa8c' end
  return '#50fa7b'
end

local function usage_icon(usage)
  local pct = tonumber(usage)
  if not pct then return '' end
  if pct >= 90 then return ' !!' end
  if pct >= 80 then return ' !' end
  return ''
end

local last_check_time = 0
local cached_ram_usage = nil
local cached_vram_pct = nil
local cached_vram_used = nil
local UPDATE_INTERVAL = 5 

local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

-- Lấy thông số RAM hệ thống
local function get_ram_usage()
  if is_windows then
    local success, stdout = wezterm.run_child_process({
      'cmd.exe', '/c', 'wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value'
    })
    if success and stdout then
      local free = stdout:match("FreePhysicalMemory=(%d+)")
      local total = stdout:match("TotalVisibleMemorySize=(%d+)")
      if free and total then
        local used = tonumber(total) - tonumber(free)
        return tostring(math.floor((used / tonumber(total)) * 100 + 0.5))
      end
    end
  elseif is_linux then
    local file = io.open("/proc/meminfo", "r")
    if file then
      local mem_total, mem_available
      for line in file:lines() do
        local total = line:match("MemTotal:%s+(%d+)")
        if total then mem_total = tonumber(total) end
        local avail = line:match("MemAvailable:%s+(%d+)")
        if avail then mem_available = tonumber(avail) end
        if mem_total and mem_available then break end
      end
      file:close()
      if mem_total and mem_available and mem_total > 0 then
        local used = mem_total - mem_available
        return tostring(math.floor((used / mem_total) * 100 + 0.5))
      end
    end
  end
  return nil
end

-- Lấy thông số VRAM từ NVIDIA GPU
local function get_vram_usage()
  local success, stdout = wezterm.run_child_process({
    'nvidia-smi',
    '--query-gpu=memory.used,memory.total',
    '--format=csv,noheader,nounits'
  })

  if success and stdout then
    local used, total = stdout:match("(%d+)[%s,]*(%d+)")
    if used and total then
      local used_num = tonumber(used)
      local total_num = tonumber(total)
      if total_num and total_num > 0 then
        local pct = tostring(math.floor((used_num / total_num) * 100 + 0.5))
        return pct, used_num
      end
    end
  end
  return nil, nil
end

function module.setup()
  wezterm.on('update-status', function(window, pane)
    local current_time = os.time()

    if current_time - last_check_time >= UPDATE_INTERVAL then
      cached_ram_usage = get_ram_usage()
      cached_vram_pct, cached_vram_used = get_vram_usage()
      last_check_time = current_time
    end

    -- Format hiển thị RAM
    local ram_disp = cached_ram_usage and (cached_ram_usage .. '%') or 'N/A'
    local ram_col  = usage_color(cached_ram_usage)
    local ram_warn = usage_icon(cached_ram_usage)

    -- Format hiển thị VRAM (hiển thị cả % và dung lượng MiB thực tế)
    local vram_disp = cached_vram_pct and (cached_vram_pct .. '% (' .. cached_vram_used .. 'MB)') or 'N/A'
    local vram_col  = usage_color(cached_vram_pct)
    local vram_warn = usage_icon(cached_vram_pct)

    window:set_right_status(wezterm.format({
      { Foreground = { Color = vram_col } },
      { Text = ' VRAM: ' .. vram_disp .. vram_warn .. ' ' },
      { Foreground = { Color = '#6272a4' } },
      { Text = '|' },
      { Foreground = { Color = ram_col } },
      { Text = ' RAM: ' .. ram_disp .. ram_warn .. ' ' },
    }))
  end)

  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.foreground_process_name or "Tab"
    title = string.gsub(title, "(.*[/\\])", "")
    return {
      { Text = " " .. title .. " " },
    }
  end)
end

return module