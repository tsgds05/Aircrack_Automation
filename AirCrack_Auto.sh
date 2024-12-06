#!/bin/bash

# check if user is running as root
if [[$EUID -ne 0]]; then
        echo "please run this as root user"
        exit 1
fi

# Kill all interfering processes
echo "[+] Killing all Interfering Processes ..."
airmon-ng check kill

# step 2  Start monitoring mode on wlan0
echo "[+] Starting monitoring mode on wlan0"
airmon-ng start wlan0

# Dynamically detect the monitoring interface name
MON_INTERFACE= $(iw dev | awk '$1=="Interface"{print $2}' | grep -E "mon$")

if [[-z $MON_INTERFACE ]]; then
        echo "[-] Monitor mode interface not detected. Exiting."
        exit 1
fi
echo "[+] Monitoring Interface Detected: $MON_INTERFACE"

# step 3 Use airodump-ng to display network
echo "[+] Scanning for networks. Press Ctrl+C to stop when you see the desired network ..."
airodump-ng wlan0 | tee -a Wifi-List.txt

# open the file in another terminal
konsole --new-tab -e nano Wifi-List.txt

# step 4  prompt user for bssid and channel
read -p "[+] Enter the target BSSID: " BSSID


read -p "[+] Enter the target Channel " CHANNEL

# step 5 start airodump-ng targeting the selected BSSID
echo "[+] Starting Targeting airodump-ng on BSSID $BSSID (channel $CHANNEL)..."
airodump-ng --bssid $BSSID -c $CHANNEL -w capture wlan0