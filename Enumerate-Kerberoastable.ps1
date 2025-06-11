<#
.SYNOPSIS
    Lists all user accounts with SPNs set (Kerberoasting targets).

.DESCRIPTION
    Queries Active Directory for user accounts that have a Service Principal Name (SPN) configured,
    which are potential targets for Kerberoasting attacks. Output is formatted for readability and
    can optionally be saved to a file.

.PARAMETER OutputFile
    Path to save the results. Defaults to 'KerberoastableAccounts.txt' in the current directory.

.PARAMETER Verbose
    If specified, provides additional progress and diagnostic information.

.EXAMPLE
    .\Enumerate-Kerberoastable.ps1 -Verbose

.EXAMPLE
    .\Enumerate-Kerberoastable.ps1 -OutputFile C:\Temp\kerberoast.txt

.NOTES
    Requires the ActiveDirectory PowerShell module and appropriate permissions to query AD users.
#>

param(
    [string]$OutputFile = "KerberoastableAccounts.txt",
    [switch]$Verbose
)

function Write-Info {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "[+] $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[-] $Message" -ForegroundColor Red
}

# Check if ActiveDirectory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-ErrorMsg "The ActiveDirectory module is not installed. Please install it and try again."
    return
}

if ($Verbose) { Write-Info "Importing ActiveDirectory module..." }
Import-Module ActiveDirectory -ErrorAction Stop

Write-Host "[+] Enumerating Kerberoastable accounts..." -ForegroundColor Cyan

try {
    if ($Verbose) { Write-Info "Querying Active Directory for users with SPNs..." }
    $users = Get-ADUser -Filter { ServicePrincipalName -like "*" } -Properties ServicePrincipalName
    if (-not $users) {
        Write-Info "No Kerberoastable accounts (users with SPNs) found."
        return
    }
} catch {
    Write-ErrorMsg "Error fetching Kerberoastable accounts: $_"
    return
}

# Format and display results
$selectProps = @{Expression = { $_.SamAccountName }; Label = "SamAccountName" },
                @{Expression = { $_.ServicePrincipalName -join ";" }; Label = "ServicePrincipalNames" }

$users | Select-Object $selectProps | Format-Table -AutoSize

# Save results to file
try {
    $users | Select-Object SamAccountName, ServicePrincipalName |
        ForEach-Object {
            "$($_.SamAccountName): $($_.ServicePrincipalName -join '; ')"
        } | Out-File -FilePath $OutputFile -Encoding UTF8

    Write-Success "Results saved to $OutputFile"
} catch {
    Write-ErrorMsg "Failed to write results to file: $_"
}
