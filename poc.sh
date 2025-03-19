#!/bin/bash

# ARP Network Segregation Validator
# Usage: sudo ./arp_validator.sh

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root (required for raw packet operations)"
    exit 1
fi

# Function to cleanup
cleanup() {
    if [ -n "$XTERM_PID" ]; then
        kill $XTERM_PID 2>/dev/null
        kill $TCPDUMP_PID 2>/dev/null
    fi
    rm -f "$LOG_FILE" 2>/dev/null
}

trap cleanup EXIT

# Get user input
read -p "Enter target IP: " TARGET_IP
read -p "Enter network interface [$(ip route get 8.8.8.8 | awk '/dev/ {print $5}')]: " INTERFACE
INTERFACE=${INTERFACE:-$(ip route get 8.8.8.8 | awk '/dev/ {print $5}')}

# Validate IP format
if ! [[ $TARGET_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "[-] Invalid IP address format"
    exit 1
fi

# Validate interface exists
if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
    echo "[-] Invalid network interface: $INTERFACE"
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="arp_capture_${TIMESTAMP}.pcap"

# Start tcpdump in xterm window
echo -e "\n[+] Launching tcpdump monitor for ARP traffic..."
xterm -title "ARP Capture on $INTERFACE" -e \
    "tcpdump -i $INTERFACE -w $LOG_FILE -s 0 'arp and host $TARGET_IP'" &
XTERM_PID=$!
TCPDUMP_PID=$(pgrep -P $XTERM_PID)

# Wait for tcpdump to start
sleep 2

# Run Nmap ARP scan
echo -e "\n[+] Scanning $TARGET_IP with ARP ping..."
nmap -sn -PR "$TARGET_IP" >/dev/null

# Wait for capture
sleep 1

# Parse results
MAC_ADDRESS=$(tcpdump -r "$LOG_FILE" 2>/dev/null | grep "arp reply" | awk '{print $7}' | sort -u)

# Display results
clear
if [ -n "$MAC_ADDRESS" ]; then
    echo -e "\n[!] Vulnerability Confirmed!"
    echo -e "─────────────────────────────"
    echo -e "Target IP:\t$TARGET_IP"
    echo -e "MAC Address:\t$MAC_ADDRESS"
    echo -e "Interface:\t$INTERFACE"
    echo -e "Capture File:\t$LOG_FILE"
    echo -e "─────────────────────────────"
else
    echo -e "\n[✓] No Vulnerability Detected"
    echo -e "─────────────────────────────"
    echo -e "No ARP response received from:"
    echo -e "Target IP:\t$TARGET_IP"
    echo -e "Interface:\t$INTERFACE"
    echo -e "─────────────────────────────"
fi

# Keep capture window open for 5 seconds
sleep 5
cleanup
