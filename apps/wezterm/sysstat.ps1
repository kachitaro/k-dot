# ==============================================================================
# Ghi RAM / VRAM ra file tạm mỗi vài giây cho thanh trạng thái WezTerm (status.lua đọc lại).
# - Chỉ chạy một bản duy nhất (mutex), status.lua tự khởi động khi file bị cũ.
# - Tự thoát khi không còn cửa sổ WezTerm nào.
# Định dạng file: "<epoch> <ram_pct> <vram_pct> <vram_used_mb>", giá trị thiếu ghi là "-".
# ==============================================================================
param (
    [string]$OutFile = (Join-Path $env:TEMP 'wezterm-sysstat.txt'),
    [int]$Interval = 5
)

$mutex = [System.Threading.Mutex]::new($false, 'Local\wezterm-sysstat')
if (-not $mutex.WaitOne(0)) { exit }

$nvidiaSmi = (Get-Command nvidia-smi -ErrorAction SilentlyContinue).Source

try {
    while (Get-Process -Name wezterm-gui -ErrorAction SilentlyContinue) {
        # FreePhysicalMemory tương đương "Available" của Task Manager (gồm cả bộ nhớ cache)
        $os = Get-CimInstance Win32_OperatingSystem
        $ram = [math]::Round((1 - $os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100)

        $vramPct = '-'
        $vramUsed = '-'
        if ($nvidiaSmi) {
            $line = & $nvidiaSmi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>$null | Select-Object -First 1
            if ($line -match '(\d+)\D+(\d+)' -and [int]$Matches[2] -gt 0) {
                $vramUsed = [int]$Matches[1]
                $vramPct = [math]::Round($vramUsed / [int]$Matches[2] * 100)
            }
        }

        $epoch = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        [System.IO.File]::WriteAllText($OutFile, "$epoch $ram $vramPct $vramUsed")
        Start-Sleep -Seconds $Interval
    }
} finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
