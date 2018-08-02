$ProfileDir = Split-Path $profile

# Add Scripts directories to path
& "$(Join-Path $PSScriptRoot scripts\Add-Path.ps1)" $(Join-Path $PSScriptRoot scripts)
if (Test-Path (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\scripts")) {
    Add-Path (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\scripts")
}

if (Test-Path ~\bin) {
    Add-Path ~\bin
}

# Setup posh-git
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
    $GitPromptSettings.DefaultPromptPath = '$(Get-ShortLocationName)'
}

# Setup Z
if (Get-Module -Name Z -ListAvailable) {
    Import-Module Z
}

# Invoke machine specific profile
if (Test-Path (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\$($MyInvocation.MyCommand.Name)")) {
    . (Join-Path $PSScriptRoot "${env:COMPUTERNAME}\$($MyInvocation.MyCommand.Name)")
}