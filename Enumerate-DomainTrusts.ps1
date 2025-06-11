<#
.SYNOPSIS
    Enumerates all domain trusts.
#>

Write-Host "[+] Enumerating domain trusts..." -ForegroundColor Cyan

try {
    Get-ADTrust -Filter * | Select-Object Name, TrustType, TrustDirection
} catch {
    Write-Warning "[-] Could not enumerate trusts. Try running as Domain Admin or use nltest."
}