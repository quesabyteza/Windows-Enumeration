<#
.SYNOPSIS
    Lists all user accounts with SPNs set (Kerberoasting targets).
#>

Write-Host "[+] Enumerating Kerberoastable accounts..." -ForegroundColor Cyan

Get-ADUser -Filter { ServicePrincipalName -like "*" } -Properties ServicePrincipalName |
Select-Object SamAccountName, ServicePrincipalName