<#
.SYNOPSIS
    Enumerates open SMB shares on one or more targets (domains, hosts, or IPs).

.DESCRIPTION
    This script connects to one or more specified targets and retrieves a list of open SMB shares,
    excluding hidden/administrative shares by default. Results are displayed and optionally logged.

.PARAMETER Targets
    The target(s) (domain name, hostnames, or IP addresses) to enumerate SMB shares from.
    Accepts a single string or an array of strings. Defaults to the current user's domain.

.PARAMETER LogPath
    Optional. Path to a log file where results will be appended.

.EXAMPLE
    PS> .\Enumerate-SMB-Shares.ps1 -Targets "DomainController1","192.168.1.5" -LogPath ".\shares.log"

#>

param(
    [Parameter(Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Targets = @("$env:USERDOMAIN"),

    [Parameter(Position=1)]
    [string]$LogPath
)

function Log-Result {
    param (
        [string]$Message
    )
    if ($LogPath) {
        $Message | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
}

foreach ($Target in $Targets) {
    Write-Host "[+] Enumerating SMB shares on $Target..." -ForegroundColor Cyan
    Log-Result "[+] Enumerating SMB shares on $Target..."

    try {
        $shares = Get-SmbShare -CimSession $Target -ErrorAction Stop | Where-Object {
            $_.Name -ne "IPC$" -and -not $_.Name.EndsWith('$')
        } | Select-Object Name, Path, Description

        if ($shares) {
            $shares | Format-Table | Out-String | ForEach-Object { Write-Host $_ }
            $shares | Out-String | ForEach-Object { Log-Result $_ }
        } else {
            Write-Warning "[-] No non-administrative SMB shares found on $Target."
            Log-Result "[-] No non-administrative SMB shares found on $Target."
        }
    } catch {
        Write-Warning "[-] Error for target $Target: $($_.Exception.Message)"
        Log-Result "[-] Error for target $Target: $($_.Exception.Message)"
    }
}
