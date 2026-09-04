#!/bin/bash

read -p "Enter a directory name: " dir_name

mkdir "$dir_name"

file_name="$dir_name/processes.txt"
touch "$file_name"

current_date=$(date)
hostname=$(hostname)
username=$(whoami)

echo "===== System Information ====="
echo "Date: $current_date"
echo "Hostname: $hostname"
echo "Username: $username"

echo ""
echo "===== Disk Usage ====="
df

echo ""
echo "===== Running Processes ====="
ps

ps > "$file_name"

echo ""
echo "Running processes have been saved to $file_name"
