function SplitParts([string]$path) {
    $parent = Split-Path $path
    if (-not $parent) {
        $path
    }
    else {
        @(SplitParts $parent) + (Split-Path $path -Leaf)
    }
}

function JoinParts([string[]]$parts) {
    $result = $parts[0]
    $parts[1..($parts.Length - 1)] | ForEach-Object { $result = Join-Path $result $_ }
    $result
}

$winWidth = $Host.UI.RawUI.WindowSize.Width
if (-not $winWidth) {
    $winWidth = 80
}
$maxWidth = [Math]::Round($winWidth / 3)
$location = (Get-Location).Path
$prefix = $HOME
$sepChar = [System.IO.Path]::DirectorySeparatorChar
if (-not $prefix.EndsWith($sepChar)) {
    $prefix += $sepChar
}
if ($location.StartsWith($prefix)) {
    $location = '~' + $location.Substring($prefix.Length - 1)
}
if ($location.Length -ge $maxWidth) {
    $pathParts = SplitParts $location
    $index = 1
    while (($location.Length -ge $maxWidth) -and ($index -lt ($pathParts.Length))) {
        $location = JoinParts (@($pathParts[0]) + @("...") + $pathParts[$index..($pathParts.Length - 1)])
        $index += 1
    }
}
$location