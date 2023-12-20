#!/bin/bash

# This script sets up a remote desktop connection using xrdp and ngrok

# Exit if not run as root
[ "$EUID" -eq 0 ] || { echo "Error: This script must be run as root. Please use sudo."; exit 1; }

# Prompt user for confirmation and root password
echo "This script will install xrdp, ngrok, change the root password, and launch xrdp on port 3389."
read -p "Do you want to continue? (y/n): " response
[ "$response" = "y" ] || exit 0
read -s -p "Enter the new root password: " root_password
echo

# Change root password and install xrdp
echo "root:$root_password" | chpasswd
apt-get update
apt-get install -y xrdp

# Download ngrok if not present and prompt user for authtoken
command -v ngrok &> /dev/null || { 
    echo "Ngrok is not installed. Downloading it now."
    wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar -xzf ngrok-v3-stable-linux-amd64.tgz
    rm ngrok-v3-stable-linux-amd64.tgz
}
read -p "Enter your ngrok authtoken: " authtoken

# Launch ngrok and xrdp in the background
./ngrok authtoken "$authtoken" && ./ngrok tcp 3389 &
xrdp &
