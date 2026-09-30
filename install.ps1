# ==============================================================================
# 🚀 Windows Dotfiles & Dev Environment Installer
# Usage:
#   # ⚡ Fast Install: Tải CLI dot và gắn cấu hình ngay
#   irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
#
# ==============================================================================

[CmdletBinding()]
param (
    [string]$DotfilesDir = "",
    [switch]$Full,            # Cài đặt toàn bộ môi trường phần mềm (Scoop, Neovim, WezTerm, Font, Tool...)
    [switch]$SkipFeatures,    # Bỏ qua kích hoạt tính năng ảo hoá Windows (Hyper-V, WSL)
    [switch]$ForceInstall     # Ghi đè file/cấu hình, buộc tải lại binary dù đã có sẵn
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

function Write-Step   { param ([string]$msg) Write-Host "`n[*] [STEP] $msg" -ForegroundColor Cyan }
function Write-Suc    { param ([string]$msg) Write-Host "  [+] $msg" -ForegroundColor Green }
function Write-Warn   { param ([string]$msg) Write-Host "  [!] $msg" -ForegroundColor Yellow }
function Write-Err    { param ([string]$msg) Write-Host "  [-] $msg" -ForegroundColor Red }
function Write-Header {
    Write-Host @"
====================================================================
  [+] KACHITARO DOTFILES & DEV ENVIRONMENT INSTALLER
  Repository: https://github.com/kachitaro/dotfiles
====================================================================
"@ -ForegroundColor Magenta
}

function Invoke-DownloadWithRetry {
    param (
        [string]$Uri,
        [string]$OutFile,
        [int]$MaxAttempts = 3,
        [int]$TimeoutSec = 60
    )
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -TimeoutSec $TimeoutSec
            return $true
        } catch {
            if ($i -eq $MaxAttempts) {
                Write-Warn "Tải thất bại sau $MaxAttempts lần thử: $($_.Exception.Message)"
                return $false
            }
            Start-Sleep -Seconds ($i * 2)
        }
    }
    return $false
}

Write-Header

if ([string]::IsNullOrWhiteSpace($DotfilesDir)) {
    if (Test-Path "$PSScriptRoot\apps\wezterm\wezterm.lua") {
        $DotfilesDir = $PSScriptRoot
    } elseif ($env:DOTFILES_DIR) {
        $DotfilesDir = $env:DOTFILES_DIR
    } else {
        $DotfilesDir = "$env:USERPROFILE\.dotfiles"
    }
}

$binDir = "$env:USERPROFILE\.local\bin"
if (!(Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$binDir;$userPath", "User")
}
if ($env:Path -notlike "*$binDir*") {
    $env:Path = "$binDir;" + $env:Path
}

[Environment]::SetEnvironmentVariable("DOTFILES_DIR", $DotfilesDir, "User")
$env:DOTFILES_DIR = $DotfilesDir

$dotExe = "$binDir\dot.exe"

$skipDownload = $false
if ((Test-Path $dotExe) -and !$ForceInstall) {
    try {
        $currentVersion = & $dotExe --version 2>$null
        if ($LASTEXITCODE -eq 0 -and $currentVersion) {
            Write-Suc "'dot' đã có sẵn ($currentVersion). Bỏ qua tải lại. Dùng -ForceInstall để tải mới."
            $skipDownload = $true
        }
    } catch { }
}

if (!$skipDownload) {
    Write-Step "Thiết lập Dotfiles CLI (dot.exe)..."
    $releaseUrl = "https://github.com/kachitaro/dotfiles/releases/latest/download/dot-x86_64-pc-windows-msvc.zip"
    $tempZip = "$env:TEMP\dot-release-$PID.zip"
    $tempExtract = "$env:TEMP\dot-release-extract-$PID"

    $installedFromRelease = $false
    try {
        Write-Host "  Đang tải binary release từ GitHub..." -ForegroundColor Gray
        if (Invoke-DownloadWithRetry -Uri $releaseUrl -OutFile $tempZip -TimeoutSec 60) {
            if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
            Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
            $extractedExe = Get-ChildItem -Path $tempExtract -Filter "dot.exe" -Recurse | Select-Object -First 1
            if ($extractedExe) {
                Copy-Item -Path $extractedExe.FullName -Destination $dotExe -Force
                $installedFromRelease = $true
                Write-Suc "Đã tải và thiết lập binary 'dot.exe' tại $dotExe"
            }
        }
    } catch {
        Write-Warn "Không thể tải release từ GitHub (offline hoặc chưa có release): $($_.Exception.Message)"
    } finally {
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    }

    if (!$installedFromRelease) {
        $localRelease = if ($PSScriptRoot) { "$PSScriptRoot\cli\target\release\dot.exe" } else { "" }
        if ($localRelease -and (Test-Path $localRelease)) {
            Copy-Item -Path $localRelease -Destination $dotExe -Force
            Write-Suc "Đã dùng binary có sẵn tại $dotExe"
        } elseif (Get-Command cargo -ErrorAction SilentlyContinue) {
            $manifest = if ($PSScriptRoot) { "$PSScriptRoot\cli\Cargo.toml" } else { "cli\Cargo.toml" }
            if (Test-Path $manifest) {
                Write-Host "  Biên dịch CLI từ mã nguồn qua Cargo..." -ForegroundColor Gray
                cargo build --release --manifest-path $manifest
                $built = (Split-Path $manifest -Parent) + "\target\release\dot.exe"
                if (Test-Path $built) {
                    Copy-Item -Path $built -Destination $dotExe -Force
                    Write-Suc "Đã biên dịch thành công 'dot.exe' vào $dotExe"
                }
            }
        }
    }
}

if ($Full) {
    Write-Step "Cấu hình PowerShell Execution Policy..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Suc "Execution Policy đã được đặt thành RemoteSigned."

    Write-Step "Kích hoạt Developer Mode (hỗ trợ Symlink)..."
    try {
        $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        if (Test-Path $devModeKey) {
            $currentVal = (Get-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
            if ($currentVal -ne 1) {
                Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile -Command Set-ItemProperty -Path '$devModeKey' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -Type DWord"
            }
        }
        Write-Suc "Developer Mode đã sẵn sàng."
    } catch {
        Write-Warn "Không thể tự động bật Developer Mode."
    }

    Write-Step "Kiểm tra và cài đặt Scoop Package Manager..."
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  Đang tải và cài đặt Scoop..." -ForegroundColor Gray
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        $env:Path = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\scoop\current\bin;" + $env:Path
    }
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Suc "Scoop đã sẵn sàng."
        $buckets = @("main", "extras", "nerd-fonts", "nonportable")
        foreach ($bucket in $buckets) {
            scoop bucket add $bucket 2>$null
        }
        scoop update
    }

    Write-Step "Cài đặt các ứng dụng và công cụ qua Scoop (batch, song song hoá cache)..."
    $corePackages = @(
        "main/git", "main/7zip", "main/curl", "main/pwsh", "main/neovim",
        "main/ripgrep", "main/fd", "main/fzf", "main/bat", "main/eza",
        "main/lazygit", "main/starship", "main/atuin",
        "main/zoxide", "main/python", "main/fnm", "main/bun",
        "vcredist-aio", "extras/wezterm", "extras/im-select", "nerd-fonts/JetBrainsMono-NF"
    )

    scoop install @corePackages --skip
    Write-Suc "Hoàn tất cài đặt các gói Scoop."

    Write-Step "Cài đặt các module PowerShell (PSReadLine, PSFzf)..."
    if (!(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    $psModules = @("PSReadLine", "PSFzf")
    foreach ($mod in $psModules) {
        if (!(Get-Module -Name $mod -ListAvailable)) {
            Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        }
    }
    Write-Suc "Modules PowerShell đã sẵn sàng."

    # Clone dotfiles repo nếu chưa có
    if (!(Test-Path "$DotfilesDir\.git")) {
        Write-Step "Đang clone dotfiles repository về $DotfilesDir..."
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $parentDir = Split-Path -Path $DotfilesDir -Parent
            if (!(Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
            git clone --depth 1 https://github.com/kachitaro/dotfiles.git $DotfilesDir
            Write-Suc "Dotfiles đã sẵn sàng tại $DotfilesDir"
        }
    }

    if (!$SkipFeatures) {
        Write-Step "Kiểm tra tính năng ảo hoá Windows..."
        $features = @("VirtualMachinePlatform", "Microsoft-Windows-Subsystem-Linux", "HypervisorPlatform")
        foreach ($feat in $features) {
            Enable-WindowsOptionalFeature -Online -FeatureName $feat -All -NoRestart -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Suc "Đã kích hoạt các tính năng ảo hoá (WSL/Hyper-V)."
    }
}

if (!(Test-Path $dotExe)) {
    Write-Err "Không thể cài đặt 'dot.exe' (không có release, không có cargo). Dừng lại."
    exit 1
}
try {
    & $dotExe --version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "exit code $LASTEXITCODE" }
} catch {
    Write-Err "Binary 'dot.exe' tại $dotExe không chạy được. Thử lại với -ForceInstall."
    exit 1
}

Write-Step "Đồng bộ liên kết cấu hình qua 'dot inject'..."
$injectArgs = @("inject")
if ($ForceInstall) { $injectArgs += "--force" }
& $dotExe @injectArgs

Write-Host @"

====================================================================
  [+] HOAN TAT THIET LAP KACHITARO DOTFILES!
====================================================================
  * Lenh 'dot' da san sang trong PATH cua ban.
  * Ban co the dung 'dot --help' de xem toan bo huong dan.
====================================================================
"@ -ForegroundColor Green