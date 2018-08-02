$IsAdmin = & {
    $wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp = new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $prp.IsInRole($adm)
}

if ($IsAdmin) {
    (get-host).UI.RawUI.Backgroundcolor="DarkRed"
}
clear-host

Set-Variable -Name ProfileDir -Value (Split-Path $profile)
$env:Editor = 'code'

# Add Scripts directories to path
& "$(Join-Path $PSScriptRoot scripts\Add-Path.ps1)" $(Join-Path $PSScriptRoot scripts)
if (Test-Path (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\scripts")) {
    Add-Path (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\scripts")
}

if (Test-Path ~\bin) {
    Add-Path ~\bin
}

# Load and customize posh-git
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
    $GitPromptSettings.DefaultPromptPath = '$(Get-ShortLocationName)'
}

# Load Z
if (Get-Module -Name Z -ListAvailable) {
    Import-Module Z
}

# Invoke machine specific profile
if (Test-Path (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\$($MyInvocation.MyCommand.Name)")) {
    . (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\$($MyInvocation.MyCommand.Name)")
}