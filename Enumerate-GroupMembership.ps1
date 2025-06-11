<#
.SYNOPSIS
    Enumerates membership of specified Active Directory groups.

.DESCRIPTION
    This script queries Active Directory to enumerate the membership of specified groups.
    It supports recursive enumeration, customizable group lists, and outputs results in a structured format.

.PARAMETER Groups
    Array of group names to enumerate. Defaults to common privileged groups.

.PARAMETER ExportCsv
    (Optional) File path to export results to a CSV file.

.PARAMETER LogFile
    (Optional) File path to log script activity and errors.

.EXAMPLE
    .\Enumerate-GroupMembership.ps1 -Groups "Domain Admins", "HR Team"

.EXAMPLE
    .\Enumerate-GroupMembership.ps1 -ExportCsv "GroupMembershipReport.csv" -LogFile "GroupMembershipLog.txt"
#>

param (
    [string[]]$Groups = @("Domain Admins", "Enterprise Admins", "Administrators"),
    [string]$ExportCsv,
    [string]$LogFile
)

function Log-Message {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    if ($LogFile) {
        Add-Content -Path $LogFile -Value "[$Level] $Message"
    }
    switch ($Level) {
        "Info"    { Write-Host $Message -ForegroundColor White }
        "Warning" { Write-Warning $Message }
        "Error"   { Write-Error $Message }
    }
}

# Collect all results in an array
$results = @()

foreach ($group in $Groups) {
    Log-Message "`n[+] Group: $group" "Info"
    try {
        # Check if group exists first
        $adGroup = Get-ADGroup -Filter { Name -eq $group } -ErrorAction Stop
        $groupMembers = Get-ADGroupMember -Identity $group -Recursive | Select-Object @{n="Group";e={$group}}, Name, SamAccountName, ObjectClass
        if ($groupMembers) {
            $results += $groupMembers
        } else {
            Log-Message "    [!] No members found in group: $group" "Warning"
        }
    } catch {
        Log-Message "[-] Failed to query group: $group. Error: $_" "Warning"
    }
}

if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
    if ($ExportCsv) {
        $results | Export-Csv -Path $ExportCsv -NoTypeInformation
        Log-Message "Results exported to $ExportCsv" "Info"
    }
} else {
    Log-Message "No group membership data collected." "Warning"
}
