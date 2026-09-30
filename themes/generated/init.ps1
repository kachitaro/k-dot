# Auto-generated PowerShell init cache by 'dot inject' / 'dot theme reload'
# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'

# --- starship init ---
Invoke-Expression (& 'C:\Users\JohnN\scoop\apps\starship\current\starship.exe' init powershell --print-full-init | Out-String)

# --- fnm init ---
$env:PATH = "C:\Users\JohnN\AppData\Local\fnm_multishells\12992_1787837640186;D:\work\dotfiles\cli\target\debug\deps;D:\work\dotfiles\cli\target\debug;C:\Users\JohnN\scoop\persist\rustup\.rustup\toolchains\stable-x86_64-pc-windows-gnu\lib\rustlib\x86_64-pc-windows-gnu\lib;C:\Users\JohnN\scoop\persist\rustup\.cargo\bin;C:\Users\JohnN\AppData\Local\fnm_multishells\4788_1787837627754;C:\Users\JohnN\scoop\apps\pwsh\current;C:/Users/JohnN/.gemini/antigravity-cli/bin;C:\Users\JohnN\.local\bin;C:\Users\JohnN\scoop\apps\pwsh\current;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\JohnN\scoop\apps\flutter\current\bin;C:\Program Files (x86)\cloudflared\;;C:\Users\JohnN\AppData\Local\Programs\Herdr\bin;D:\work\dotfiles\bin;C:\Users\JohnN\scoop\apps\vscode\current\bin;C:\Users\JohnN\scoop\apps\starship\current;C:\Users\JohnN\scoop\apps\flutter\current\bin;C:\Users\JohnN\scoop\apps\gcc\current\bin;C:\Users\JohnN\AppData\Local\agy\bin;C:\Users\JohnN\scoop\apps\rustup\current\.cargo\bin;C:\Users\JohnN\scoop\apps\python\current\Scripts;C:\Users\JohnN\scoop\apps\python\current;C:\Users\JohnN\AppData\Local\Android\Sdk\emulator;C:\Users\JohnN\AppData\Local\Android\Sdk\platforms;C:\Users\JohnN\AppData\Local\Android\Sdk\platform-tools;C:\Users\JohnN\scoop\shims;C:\Users\JohnN\AppData\Local\Microsoft\WindowsApps;C:\Users\JohnN\.dotnet\tools;C:\msys64\mingw64\bin;C:\Users\JohnN\AppData\Local\Microsoft\WinGet\Links;C:\Program Files\Git\bin\bash.exe;C:\Program Files\Sublime Text\;C:\Users\JohnN\AppData\Local\agy\bin;C:\Users\JohnN\AppData\Local\Programs\Ollama;C:\Users\JohnN\AppData\Local\tglow;C:\Users\JohnN\scoop\persist\rustup\.rustup\toolchains\stable-x86_64-pc-windows-gnu\bin"
$env:FNM_MULTISHELL_PATH = "C:\Users\JohnN\AppData\Local\fnm_multishells\12992_1787837640186"
$env:FNM_VERSION_FILE_STRATEGY = "local"
$env:FNM_DIR = "C:\Users\JohnN\scoop\apps\fnm\current"
$env:FNM_LOGLEVEL = "info"
$env:FNM_NODE_DIST_MIRROR = "https://nodejs.org/dist"
$env:FNM_COREPACK_ENABLED = "false"
$env:FNM_RESOLVE_ENGINES = "true"
$env:FNM_ARCH = "x64"
function global:Set-FnmOnLoad { If ((Test-Path .nvmrc) -Or (Test-Path .node-version) -Or (Test-Path package.json)) { & fnm use --silent-if-unchanged }
 }
function global:Set-LocationWithFnm { param($path); if ($path -eq $null) {Set-Location} else {Set-Location $path}; Set-FnmOnLoad }
Set-Alias -Scope global cd_with_fnm Set-LocationWithFnm
Set-Alias -Option AllScope -Scope global cd Set-LocationWithFnm


# --- zoxide init ---
# =============================================================================
#
# Utility functions for zoxide.
#

# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    } finally {
        [Console]::OutputEncoding = $encoding
    }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd {
    $cwd = Microsoft.PowerShell.Management\Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        if ($null -eq $dir) {
            Microsoft.PowerShell.Management\Set-Location
        } else {
            Microsoft.PowerShell.Management\Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
        }
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Microsoft.PowerShell.Utility\Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Microsoft.PowerShell.Utility\Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Microsoft.PowerShell.Management\Set-Location -Path $dir -Passthru -ErrorAction Stop
        }
    }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add "--" $result
        }
        $global:__zoxide_oldpwd = $result
    }
}

# Initialize hook.
$global:__zoxide_hooked = (Microsoft.PowerShell.Utility\Get-Variable __zoxide_hooked -ErrorAction Ignore -ValueOnly)
if ($global:__zoxide_hooked -ne 1) {
    $global:__zoxide_hooked = 1
    $global:__zoxide_prompt_old = $function:prompt

    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd $null $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Microsoft.PowerShell.Management\Test-Path -PathType Container -LiteralPath $args[0])) {
        __zoxide_cd $args[0] $true
    }
    elseif ($args.Length -eq 1 -and (Microsoft.PowerShell.Management\Test-Path -PathType Container -Path $args[0] )) {
        __zoxide_cd $args[0] $false
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result "--" @args
        }
        else {
            $result = __zoxide_bin query "--" @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi {
    $result = __zoxide_bin query -i "--" @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

Microsoft.PowerShell.Utility\Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Microsoft.PowerShell.Utility\Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# =============================================================================
#
# To initialize zoxide, add this to your configuration (find it by running
# `echo $profile` in PowerShell):
#
# Invoke-Expression (& { (zoxide init powershell | Out-String) })

# --- atuin init ---
# Atuin PowerShell module
#
# This should support PowerShell 5.1 (which is shipped with Windows) and later versions, on Windows and Linux.
#
# Usage: atuin init powershell | Out-String | Invoke-Expression
#
# Settings:
# - $env:ATUIN_POWERSHELL_PROMPT_OFFSET - Number of lines to offset the prompt position after exiting search.
#   This is useful when using a multi-line prompt: e.g. set this to -1 when using a 2-line prompt.
#   It is initialized from the current prompt line count if not set when the first Atuin search is performed.

if (Get-Module Atuin -ErrorAction Ignore) {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-Warning "The Atuin module is already loaded, replacing it."
        Remove-Module Atuin
    } else {
        Write-Warning "The Atuin module is already loaded, skipping."
        return
    }
}

if (!(Get-Command atuin -ErrorAction Ignore)) {
    Write-Error "The 'atuin' executable needs to be available in the PATH."
    return
}

if (!(Get-Module PSReadLine -ErrorAction Ignore)) {
    Write-Error "Atuin requires the PSReadLine module to be installed."
    return
}

New-Module -Name Atuin -ScriptBlock {
    if (-not $env:ATUIN_SESSION -or $env:ATUIN_PID -ne $PID) {
        $env:ATUIN_SESSION = atuin uuid
        $env:ATUIN_PID = $PID
    }

    $script:atuinHistoryId = $null
    $script:previousPSConsoleHostReadLine = $Function:PSConsoleHostReadLine

    # The ReadLine overloads changed with breaking changes over time, make sure the one we expect is available.
    $script:hasExpectedReadLineOverload = ([Microsoft.PowerShell.PSConsoleReadLine]::ReadLine).OverloadDefinitions.Contains("static string ReadLine(runspace runspace, System.Management.Automation.EngineIntrinsics engineIntrinsics, System.Threading.CancellationToken cancellationToken, System.Nullable[bool] lastRunStatus)")

    function Get-CommandLine {
        $commandLine = ""
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$commandLine, [ref]$null)
        return $commandLine
    }

    function Set-CommandLine {
        param([string]$Text)

        $commandLine = Get-CommandLine
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $commandLine.Length, $Text)
    }

    # This function name is called by PSReadLine to read the next command line to execute.
    # We replace it with a custom implementation which adds Atuin support.
    function PSConsoleHostReadLine {
        ## 1. Collect the exit code of the previous command.

        # This needs to be done as the first thing because any script run will flush $?.
        $lastRunStatus = $?

        # Exit statuses are maintained separately for native and PowerShell commands, this needs to be taken into account.
        $lastNativeExitCode = $global:LASTEXITCODE
        $exitCode = if ($lastRunStatus) { 0 } elseif ($lastNativeExitCode) { $lastNativeExitCode } else { 1 }

        ## 2. Report the status of the previous command to Atuin (atuin history end).

        if ($script:atuinHistoryId) {
            try {
                # The duration is not recorded in old PowerShell versions, let Atuin handle it. $null arguments are ignored.
                $duration = (Get-History -Count 1).Duration.Ticks * 100
                $durationArg = if ($duration) { "--duration=$duration" } else { $null }

                # Fire and forget the atuin history end command to avoid blocking the shell during a potential sync.
                $process = New-Object System.Diagnostics.Process
                $process.StartInfo.FileName = "atuin"
                $process.StartInfo.Arguments = "history end --hook --exit=$exitCode $durationArg -- $script:atuinHistoryId"
                $process.StartInfo.UseShellExecute = $false
                $process.StartInfo.CreateNoWindow = $true
                $process.StartInfo.RedirectStandardInput = $true
                $process.StartInfo.RedirectStandardOutput = $true
                $process.StartInfo.RedirectStandardError = $true
                $process.Start() | Out-Null
                $process.StandardInput.Close()
                $process.BeginOutputReadLine()
                $process.BeginErrorReadLine()
            }
            catch {
                # Ignore errors to avoid breaking the shell.
                # An error would occur if the user removes atuin from the PATH, for instance.
            }
            finally {
                $script:atuinHistoryId = $null
            }
        }

        ## 3. Read the next command line to execute.

        # PSConsoleHostReadLine implementation from PSReadLine, adjusted to support old versions.
        Microsoft.PowerShell.Core\Set-StrictMode -Off

        $line = if ($script:hasExpectedReadLineOverload) {
            # When the overload we expect is available, we can pass $lastRunStatus to it.
            [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine($Host.Runspace, $ExecutionContext, [System.Threading.CancellationToken]::None, $lastRunStatus)
        } else {
            # Either PSReadLine is older than v2.2.0-beta3, or maybe newer than we expect, so use the function from PSReadLine as-is.
            & $script:previousPSConsoleHostReadLine
        }

        ## 4. Report the next command line to Atuin (atuin history start).

        # PowerShell doesn't handle double quotes in native command line arguments the same way depending on its version,
        # and the value of $PSNativeCommandArgumentPassing - see the about_Parsing help page which explains the breaking changes.
        # This makes it unreliable, so we go through an environment variable, which should always be consistent across versions.
        $prevCommandLine = $env:ATUIN_COMMAND_LINE
        $prevShell = $env:ATUIN_SHELL
        try {
            $env:ATUIN_COMMAND_LINE = $line
            $env:ATUIN_SHELL = "powershell"
            $script:atuinHistoryId = atuin history start --hook --command-from-env
        }
        catch {
            # Ignore errors to avoid breaking the shell, see above.
        }
        finally {
            $env:ATUIN_COMMAND_LINE = $prevCommandLine
            $env:ATUIN_SHELL = $prevShell
        }

        $global:LASTEXITCODE = $lastNativeExitCode
        return $line
    }

    function Invoke-AtuinSearch {
        param([string]$ExtraArgs = "")

        $previousOutputEncoding = [System.Console]::OutputEncoding
        $resultFile = New-TemporaryFile
        $suggestion = ""
        $errorOutput = ""

        try {
            [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

            # Start-Process does some crazy stuff, just use the Process class directly to have more control.
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo.FileName = "atuin"
            $process.StartInfo.Arguments = "search -i --result-file ""$($resultFile.FullName)"" $ExtraArgs"
            $process.StartInfo.UseShellExecute = $false
            $process.StartInfo.RedirectStandardError = $true
            $process.StartInfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8
            $process.StartInfo.EnvironmentVariables["ATUIN_SHELL"] = "powershell"
            $process.StartInfo.EnvironmentVariables["ATUIN_QUERY"] = Get-CommandLine
            # PowerShell's Set-Location (cd) doesn't update the process-level working directory, set it explicitly
            $process.StartInfo.WorkingDirectory = (Get-Location -PSProvider FileSystem).ProviderPath

            try {
                $process.Start() | Out-Null

                # A single stream is redirected, so we can read it synchronously, but we have to start reading it
                # before waiting for the process to exit, otherwise the buffer could fill up and cause a deadlock.
                $errorOutput = $process.StandardError.ReadToEnd().Trim()
                $process.WaitForExit()

                $suggestion = (Get-Content -LiteralPath $resultFile.FullName -Raw -Encoding UTF8 | Out-String).Trim()
            }
            catch {
                $errorOutput = $_
            }

            if ($errorOutput) {
                Write-Host -ForegroundColor Red "Atuin error:"
                Write-Host -ForegroundColor DarkRed $errorOutput
            }

            # If no shell prompt offset is set, initialize it from the current prompt line count.
            if ($null -eq $env:ATUIN_POWERSHELL_PROMPT_OFFSET) {
                try {
                    $promptLines = (& $Function:prompt | Out-String | Measure-Object -Line).Lines
                    $env:ATUIN_POWERSHELL_PROMPT_OFFSET = -1 * ($promptLines - 1)
                }
                catch {
                    $env:ATUIN_POWERSHELL_PROMPT_OFFSET = 0
                }
            }

            # PSReadLine maintains its own cursor position, which will no longer be valid if Atuin scrolls the display in inline mode.
            # Fortunately, InvokePrompt can receive a new Y position and reset the internal state.
            $y = $Host.UI.RawUI.CursorPosition.Y + [int]$env:ATUIN_POWERSHELL_PROMPT_OFFSET
            $y = [System.Math]::Max([System.Math]::Min($y, [System.Console]::BufferHeight - 1), 0)
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, $y)

            if ($suggestion -eq "") {
                # The previous input was already rendered by InvokePrompt
                return
            }

            $acceptPrefix = "__atuin_accept__:"

            if ( $suggestion.StartsWith($acceptPrefix)) {
                Set-CommandLine $suggestion.Substring($acceptPrefix.Length)
                [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
            } else {
                Set-CommandLine $suggestion
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousOutputEncoding
            $resultFile.Delete()
        }
    }

    function Enable-AtuinSearchKeys {
        param([bool]$CtrlR = $true, [bool]$UpArrow = $true)

        if ($CtrlR) {
            Set-PSReadLineKeyHandler -Chord "Ctrl+r" -BriefDescription "Runs Atuin search" -ScriptBlock {
                Invoke-AtuinSearch
            }
        }

        if ($UpArrow) {
            Set-PSReadLineKeyHandler -Chord "UpArrow" -BriefDescription "Runs Atuin search" -ScriptBlock {
                $line = Get-CommandLine

                if (!$line.Contains("`n")) {
                    Invoke-AtuinSearch -ExtraArgs "--shell-up-key-binding"
                } else {
                    [Microsoft.PowerShell.PSConsoleReadLine]::PreviousLine()
                }
            }
        }
    }

    $ExecutionContext.SessionState.Module.OnRemove += {
        $env:ATUIN_SESSION = $null
        $Function:PSConsoleHostReadLine = $script:previousPSConsoleHostReadLine
    }

    Export-ModuleMember -Function @("Enable-AtuinSearchKeys", "PSConsoleHostReadLine")
} | Import-Module -Global
Enable-AtuinSearchKeys -CtrlR $true -UpArrow $false

