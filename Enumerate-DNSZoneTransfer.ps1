<#
.SYNOPSIS
    Attempts a DNS zone transfer on the current domain using nslookup.
#>

$domain = (Get-ADDomain).DNSRoot
Write-Host "[+] Attempting DNS zone transfer on $domain..." -ForegroundColor Cyan

$dns = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses[0]

$output = nslookup -type=any $domain $dns

if ($output -like "*nameserver*") {
    Write-Output $output
} else {
    Write-Warning "[-] Zone transfer failed or not permitted."
}