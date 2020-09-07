# I customize the shell to use 16pt Consolas with a window opacity of 90%
# If I knew how you could change that programatically I'd automate this bit.

$DefaultUser = 'e79209@B9FG5Q2'

$PSDefaultParameterValues.Add('Invoke-WebRequest:Proxy','https://104.129.194.36:443')
$PSDefaultParameterValues.Add('Invoke-WebRequest:ProxyUseDefaultCredentials',$true)
 
# Detect elevation
$IsAdmin = & {
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

# Configure environment variables
Set-Variable -Name ProfileDir -Value (Split-Path $profile)
if (Get-Command 'code' -ErrorAction SilentlyContinue) {
    $env:Editor = 'code'
}
else {
    $env:Editor = "notepad"
}

# Dot source functions
(Join-Path $PSScriptRoot 'Functions'),(Join-Path $PSScriptRoot "${env:COMPUTERNAME}\Functions") |
    Where-Object { Test-Path $_ } |
    ForEach-Object {
        Get-ChildItem $_ | ForEach-Object {
            . $_.FullName
        }
    }

# If we have a bin folder add it to the path
if (Test-Path ~\bin) {
    Add-Path ~\bin
}

# Load and customize posh-git
# Colors are optimized for a console window with a background color of black
# and match my cutomized git configuration:
# [color]
#     ui = true
# [color "status"]
#     changed = yellow bold
#     untracked = cyan bold
#     added = green bold
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git
    $GitPromptSettings.DefaultPromptPath = '$(Get-ShortLocationName)'
    $GitPromptSettings.DefaultPromptPath.ForegroundColor = 'Orange'
    $GitPromptSettings.WorkingColor.ForegroundColor = 'Yellow'
    $GitPromptSettings.IndexColor.ForegroundColor = 'Lime'
    $GitPromptSettings.LocalWorkingStatusSymbol = "$([char]27)[1;31m!$([char]27)[0m" # bold red instead of plain red
    $GitPromptSettings.DefaultPromptSuffix = " $('→' * ($nestedPromptLevel + 1)) "
    if ($IsAdmin) {
        $GitPromptSettings.DefaultPromptPath.ForegroundColor = 'Red'
        $GitPromptSettings.DefaultPromptSuffix.ForegroundColor = 'Red'
        }
    }

# Load Z
if (Get-Module -Name Z -ListAvailable) {
    Import-Module Z
}

# Invoke machine specific profile
@(Join-Path $PSScriptRoot "${env:COMPUTERNAME}\$($MyInvocation.MyCommand.Name)") |
    Where-Object { Test-Path $_ } |
    ForEach-Object { . $_ }
 
# The following command can turn on Virtual Terminal (ANSI escape code) support for all
# processes. This *may* break some things, so I may need to remove this value in the
# future?
# set-itemproperty -path hkcu:\console -name VirtualTerminalLevel -Value 1
 
Set-Theme wek
$ThemeSettings.Colors.AdminIconForegroundColor = 'Red'
$ThemeSettings.Colors.GitForegroundColor = 'White'
$ThemeSettings.Colors.GitDefaultColor = 'DarkGreen'
$ThemeSettings.Colors.GitLocalChangesColor = 'DarkMagenta'
$ThemeSettings.Colors.GetNoLocalChangesAndAheadColor = 'GoldenRod'

# PowerShell parameter completion shim for the dotnet CLI 
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}