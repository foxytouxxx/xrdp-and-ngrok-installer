#!/bin/bash

# Function to display an error message and exit
function display_error() {
    echo "Error: $1"
    exit 1
}

# Function to prompt user for confirmation
function prompt_confirmation() {
    read -p "$1 (y/n): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0  # User confirmed
    else
        return 1  # User did not confirm
    fi
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    display_error "This script must be run as root. Please use sudo."
fi

# Display a warning and prompt for confirmation
echo "This script will install xrdp, ngrok, change the root password, and launch xrdp on port 3389."
prompt_confirmation "Do you want to continue?"

# Prompt user for root password
read -s -p "Enter the new root password: " root_password
echo

# Change root password
echo "root:$root_password" | chpasswd

# Install xrdp
apt-get update
apt-get install -y xrdp

# Check if ngrok is already present
if ! command -v ngrok &> /dev/null; then
    prompt_confirmation "Ngrok is not installed. Do you want to download it?"

    # Download and extract ngrok with --no-check-certificate option
    wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar -xzf ngrok-v3-stable-linux-amd64.tgz
    rm ngrok-v3-stable-linux-amd64.tgz
fi

# Prompt user for ngrok authtoken
read -p "Enter your ngrok authtoken: " authtoken

# Set ngrok authtoken
./ngrok authtoken "$authtoken"

# Start xrdp on port 3389
systemctl start xrdp

# Launch ngrok with --no-check-certificate option
./ngrok tcp 3389
