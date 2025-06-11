# Active Directory Enumeration Scripts

A collection of PowerShell scripts created by **Michael van Staden** for internal penetration testing and Active Directory enumeration. Each script targets a common AD misconfiguration or exposure vector useful in privilege escalation and information gathering during assessments.

---

## 🔍 Included Scripts

### 1. `Enumerate-SMB-Shares.ps1`
- Lists all accessible SMB shares on a target domain or host.
- Skips default administrative shares like `IPC$`.
- Useful for finding open shares with potentially sensitive files.

**Usage:**
```powershell
.\Enumerate-SMB-Shares.ps1 -Target TARGET_DOMAIN_OR_HOST
```

### 2.`Enumerate-Kerberoastable.ps1`
Identifies user accounts with SPNs set (Kerberoasting targets).

Helps locate accounts that can be attacked via offline TGS ticket cracking.

**Usage:**

```powershell

.\Enumerate-Kerberoastable.ps1
```

### 3. Enumerate-DomainTrusts.ps1
Lists all domain trusts and trust relationships.

Useful for mapping external trust exposure and lateral movement opportunities.

**Usage:**

```powershell

.\Enumerate-DomainTrusts.ps1
```

### 4. Enumerate-GroupMembership.ps1
Recursively lists members of critical domain groups like:

Domain Admins

Enterprise Admins

Administrators

Helps identify privileged users and group escalation vectors.

**Usage:**

```powershell

.\Enumerate-GroupMembership.ps1
```

### 5. Enumerate-DNSZoneTransfer.ps1
Attempts a DNS zone transfer against the current domain controller.

Uses nslookup to dump DNS records (if zone transfers are misconfigured).

**Usage:**

```powershell

.\Enumerate-DNSZoneTransfer.ps1
```
### 6. Get-The-Hash.sh

**Usage:**
Save as Get-The-Hash.sh
```terminal
chmod +x Get-The-Hash.sh
sudo apt install impacket-scripts smbclient (if not already installed)
./win-creds-remote.sh
```
Features
Menu-driven
Secure credential or hash input
Automates remote shadow copy and registry save extraction over SMB (using psexec.py)
Downloads files via SMB and dumps hashes locally
Guidance for Metasploit keylogging/hashdump
Cleans up after itself

⚠️ Legal Notice
These tools are intended solely for authorized, ethical, and educational use. Unauthorized use on production systems or networks without explicit consent is unethical and illegal. Use responsibly and always obtain proper authorization.

👤 Author
Michael van Staden
🔐 Pentester-in-Training | Security Enthusiast
🔗 GitHub: quesabyteza

📂 Repository Goal
This project aims to be a practical toolkit for penetration testers and red teamers focusing on real-world Windows Active Directory enumeration. Future additions may include:

Exploitation scripts (e.g. AS-REP Roasting, PrinterBug)

Post-exploitation tooling (e.g. token impersonation, privilege escalation)

Lateral movement helpers

Feel free to fork, improve, and contribute.
