# ==============================================================================
# Dotfiles PowerShell Configuration
# ==============================================================================

if ($global:__DOTFILES_PROFILE_LOADED -and -not $env:FORCE_DOTFILES_RELOAD) {
    return
}
$global:__DOTFILES_PROFILE_LOADED = $true

# ------------------------------------------------------------------------------
# 1. Environment & Encodings
# ------------------------------------------------------------------------------
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:LESSCHARSET = 'utf-8'

# Eza, Bat & Fzf Environment Variables
$env:EZA_COLORS = "di=36"
$env:FZF_DEFAULT_OPTS = "--height 50% --layout=reverse --border --info=inline"
$env:FZF_ALT_C_OPTS   = "--preview 'eza -a --tree --level=2 --color=always --icons=always {}' --preview-window 'right:55%,border-left'"
$env:BAT_CONFIG_DIR   = "$env:USERPROFILE\.config\bat"
$env:BAT_CONFIG_PATH  = "$env:USERPROFILE\.config\bat\config"


# ------------------------------------------------------------------------------
# 2. PSReadLine Foundation (Bắt buộc load ĐẦU TIÊN)
# ------------------------------------------------------------------------------
Import-Module PSReadLine -ErrorAction SilentlyContinue
if (Get-Module -Name PSReadLine) {
    try {
        Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
        Set-PSReadLineOption -MaximumHistoryCount 100 -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue

        $histPath = (Get-PSReadLineOption).HistorySavePath
        if ($histPath -and (Test-Path $histPath)) {
            $fileInfo = Get-Item $histPath -ErrorAction SilentlyContinue
            if ($fileInfo -and $fileInfo.Length -gt 15KB) {
                $lines = [System.IO.File]::ReadAllLines($histPath)
                if ($lines.Length -gt 150) {
                    $recent = $lines[($lines.Length - 100)..($lines.Length - 1)]
                    [System.IO.File]::WriteAllLines($histPath, $recent)
                }
            }
        }
    } catch {}
}

# ------------------------------------------------------------------------------
# 3. PSFzf (Chỉ lấy Ctrl+F, NHƯỜNG Ctrl+R cho Atuin)
# ------------------------------------------------------------------------------
Import-Module PSFzf -ErrorAction SilentlyContinue
if (Get-Module -Name PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f'
}

# ------------------------------------------------------------------------------
# 4. Modern CLI Tools (Phải load SAU PSReadLine để ghi đè phím)
# ------------------------------------------------------------------------------
$cachedInitPs1 = if ($env:DOTFILES_DIR) { Join-Path $env:DOTFILES_DIR "themes\generated\init.ps1" } else { $null }
if ($cachedInitPs1 -and (Test-Path $cachedInitPs1)) {
    . $cachedInitPs1
} else {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (&starship init powershell)
    }

    if (Get-Command fnm -ErrorAction SilentlyContinue) {
        fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
    }

    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        zoxide init powershell | Out-String | Invoke-Expression
    }

    if (Get-Command atuin -ErrorAction SilentlyContinue) {
        Invoke-Expression ((&atuin init powershell --disable-up-arrow) -join "`n")
    }
}

# ------------------------------------------------------------------------------
# 5. Aliases & Functions
# ------------------------------------------------------------------------------
Set-Alias g git -ErrorAction SilentlyContinue
Set-Alias vim nvim -ErrorAction SilentlyContinue
Set-Alias vi nvim -ErrorAction SilentlyContinue

$usrBinPath = Join-Path $env:USERPROFILE "scoop\apps\git\current\usr\bin"
if (Test-Path (Join-Path $usrBinPath "tig.exe")) { Set-Alias tig (Join-Path $usrBinPath "tig.exe") -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $usrBinPath "less.exe")) { Set-Alias less (Join-Path $usrBinPath "less.exe") -ErrorAction SilentlyContinue }

# --- Thay thế 'cat' bằng 'bat' ---
Remove-Item alias:cat -Force -ErrorAction SilentlyContinue
function cat { bat --paging=never $args }
function b { bat $args }

# --- Thay thế 'ls' bằng 'eza' ---
Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
function ls { eza --color=always --icons=always --group-directories-first $args }
function ll { eza -al --color=always --icons=always --group-directories-first --git --time-style=long-iso --color-scale $args }
function la { eza -a --color=always --icons=always --group-directories-first $args }
function lt { eza -a --tree --level=3 --color=always --icons=always --group-directories-first $args }

# ------------------------------------------------------------------------------
# 6. Load External Scripts & Themes
# ------------------------------------------------------------------------------
if (-not $env:DOTFILES_DIR -and $PSScriptRoot) {
    $parentDir = Split-Path -Path $PSScriptRoot -Parent
    if (Test-Path (Join-Path $parentDir "themes")) {
        $env:DOTFILES_DIR = $parentDir
    } else {
        $grandParent = Split-Path -Path $parentDir -Parent
        if ($grandParent -and (Test-Path (Join-Path $grandParent "themes"))) {
            $env:DOTFILES_DIR = $grandParent
        } else {
            $env:DOTFILES_DIR = $parentDir
        }
    }
}
if ($env:DOTFILES_DIR -and (Test-Path "$env:DOTFILES_DIR\bin")) {
    if ($env:PATH -notlike "*$env:DOTFILES_DIR\bin*") {
        $env:PATH = "$env:DOTFILES_DIR\bin;" + $env:PATH
    }
}
$localBin = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path $localBin) {
    if ($env:PATH -notlike "*$localBin*") {
        $env:PATH = "$localBin;" + $env:PATH
    }
}

# Load functions.ps1
$funcPath = Join-Path $PSScriptRoot "functions.ps1"
if (-not (Test-Path $funcPath)) {
    $funcPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\powershell\functions.ps1"
}
if (Test-Path -Path $funcPath) {
    . $funcPath
} else {
    Write-Warning "Không tìm thấy file functions.ps1 tại: $funcPath"
}

# Load Themes
$theme_candidates = @(
    $(if ($env:DOTFILES_DIR) { Join-Path $env:DOTFILES_DIR "themes\generated\theme.ps1" }),
    "$env:USERPROFILE\.dotfiles\themes\generated\theme.ps1",
    "$env:USERPROFILE\.config\themes\generated\theme.ps1"
)
foreach ($t_path in $theme_candidates) {
    if ($t_path -and (Test-Path $t_path)) {
        . $t_path
        break
    }
}