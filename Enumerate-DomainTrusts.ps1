<#
.SYNOPSIS
    Enumerates all domain trusts.

.DESCRIPTION
    This script uses the Get-ADTrust cmdlet to retrieve information about domain trusts. 
    It supports filtering and verbose logging options and saves the results to a log file.

.PARAMETER Filter
    The LDAP filter to apply when retrieving trusts. Default is '*'.

.PARAMETER VerboseOutput
    Enables verbose logging for debugging and runtime information.

.EXAMPLE
    .\Enumerate-DomainTrusts.ps1 -VerboseOutput

.NOTES
    Author: Michael van Staden
    Date: 2025-06-11
#>

param (
    [string]$Filter = "*",
    [switch]$VerboseOutput
)

Write-Host "[+] Enumerating domain trusts..." -ForegroundColor Cyan

# Validate cmdlet availability
if (-not (Get-Command -Name Get-ADTrust -ErrorAction SilentlyContinue)) {
    Write-Warning "[-] The 'Get-ADTrust' cmdlet is not available. Ensure the Active Directory module is installed."
    return
}

# Attempt enumeration
$OutputFile = "DomainTrusts_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
try {
    $Results = Get-ADTrust -Filter $Filter | Select-Object Name, TrustType, TrustDirection
    $Results | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "[+] Enumeration completed. Output saved to $OutputFile" -ForegroundColor Green

    if ($VerboseOutput) {
        Write-Host "[+] Results:" -ForegroundColor Yellow
        $Results | Format-Table
    }
} catch {
    Write-Warning "[-] Could not enumerate trusts. Error: $($_.Exception.Message)"
    Write-Warning "[-] Try running as Domain Admin or use 'nltest /domain_trusts'."
}
