<#
.SYNOPSIS
    Attempts a DNS zone transfer on the current domain using nslookup.
#>

$domain = (Get-ADDomain).DNSRoot
$dns = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses[0]
Write-Host "[+] Attempting DNS zone transfer on $domain using $dns..." -ForegroundColor Cyan

$output = nslookup.exe -querytype=AXFR $domain $dns

if ($output -match "received \d+ records") {
    Write-Output $output
} else {
    Write-Warning "[-] Zone transfer failed or not permitted."
}

