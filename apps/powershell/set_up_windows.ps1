# Wrapper script để chạy installer chính
$installScript = Join-Path $PSScriptRoot "..\install.ps1"
if (Test-Path $installScript) {
    & $installScript @args
} else {
    Write-Host "Downloading and running latest installer..." -ForegroundColor Cyan
    irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
}