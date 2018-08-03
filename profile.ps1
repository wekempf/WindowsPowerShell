# I customize the shell to use 16pt Consolas with a window opacity of 90%
# If I knew how you could change that programatically I'd automate this bit.

# Detect elevation
$IsAdmin = & {
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

# If elevated, set the background to red in order to easily identify this
if ($IsAdmin) {
    (get-host).UI.RawUI.Backgroundcolor="DarkRed"
}
clear-host

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
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
    $GitPromptSettings.DefaultPromptPath = '$(Get-ShortLocationName)'

    Start-SshAgent

    function g {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $False, ValueFromRemainingArguments = $True)]
            $Arguments
        )
        if (-not $Arguments) {
            $Arguments = @('status')
        }
        git @Arguments
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