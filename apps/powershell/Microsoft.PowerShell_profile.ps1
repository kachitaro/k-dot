# Load dotfiles user profile
$profileTarget = if ($env:DOTFILES_DIR -and (Test-Path "$env:DOTFILES_DIR\apps\powershell\user_profile.ps1")) {
    "$env:DOTFILES_DIR\apps\powershell\user_profile.ps1"
} elseif (Test-Path "$env:USERPROFILE\.dotfiles\apps\powershell\user_profile.ps1") {
    "$env:USERPROFILE\.dotfiles\apps\powershell\user_profile.ps1"
} else {
    "$env:USERPROFILE\.config\powershell\user_profile.ps1"
}
if (Test-Path $profileTarget) { . $profileTarget }
