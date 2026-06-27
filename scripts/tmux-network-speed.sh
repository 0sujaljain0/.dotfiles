#!/bin/bash
# ~/.tmux/network_speed.sh

INTERFACE="eth0"

# Read initial bytes
R1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
T1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Wait 1 second to calculate bytes per second
sleep 1

# Read bytes again
R2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
T2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Calculate difference and convert to KB/s
RX_KBS=$(( (R2 - R1) / 1024 ))
TX_KBS=$(( (T2 - T1) / 1024 ))

echo "↓ ${RX_KBS}KB/s ↑ ${TX_KBS}KB/s"
