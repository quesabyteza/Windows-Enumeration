<#
.SYNOPSIS
    Enumerates open SMB shares on a domain from a given subnet or host list.
#>

param(
    [string]$Target = "$env:USERDOMAIN"
)

Write-Host "[+] Enumerating SMB shares on $Target..." -ForegroundColor Cyan

try {
    Get-SmbShare -CimSession $Target | Where-Object { $_.Name -ne "IPC$" } |
    Select-Object Name, Path, Description
} catch {
    Write-Warning "[-] Access denied or host not reachable: $Target"
}