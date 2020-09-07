function New-Hardlink {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        $Source,
        [Parameter(Position = 1)]
        $Target
    )
    
    begin {
        $Source = Resolve-Path $Source -ErrorAction Stop
        $Target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)
    }
    
    process {
        Invoke-Expression "cmd /c mklink /h `"$Target`" `"$Source`""
    }
    
    end {
    }
}
