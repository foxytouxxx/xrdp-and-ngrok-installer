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
echo "This script will install xrdp and ngrok, and launch xrdp on port 3389."
prompt_confirmation "Do you want to continue?"

# Install xrdp
apt-get update
apt-get install -y xrdp

# Install ngrok
if ! command -v ngrok &> /dev/null; then
    prompt_confirmation "Ngrok is not installed. Do you want to install it?"
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    unzip ngrok-v3-stable-linux-amd64.tgz
    mv ngrok /usr/local/bin/
    rm ngrok-stable-linux-amd64.zip
fi

# Prompt user for ngrok authtoken
read -p "Enter your ngrok authtoken: " authtoken

# Save ngrok authtoken to configuration file
echo "authtoken: $authtoken" > ~/.ngrok2/ngrok.yml

# Start xrdp on port 3389
systemctl start xrdp

echo "xrdp and ngrok installation completed successfully. You can now connect to your machine using an RDP client on port 3389."
