<#
.SYNOPSIS
    Enumerates membership of high-value groups (e.g. Domain Admins, Enterprise Admins).
#>

$groups = @("Domain Admins", "Enterprise Admins", "Administrators")

foreach ($group in $groups) {
    Write-Host "`n[+] Group: $group" -ForegroundColor Cyan
    try {
        Get-ADGroupMember -Identity $group -Recursive | Select-Object Name, SamAccountName, objectClass
    } catch {
        Write-Warning "[-] Failed to query group: $group"
    }
}