#!/bin/bash

# ==============================================================================
# Inception Project - Initial Server Setup Script for Debian
# ==============================================================================
# This script automates the installation of essential tools for the 42 Inception
# project on a fresh Debian server.
#
# It performs the following actions:
# 1. Updates and upgrades system packages.
# 2. Installs basic utilities (sudo, git, curl, make, ufw).
# 3. Installs Docker and Docker Compose from Docker's official repository.
# 4. Configures the Uncomplicated Firewall (UFW).
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (reset)

# --- 1. System Update and Upgrade ---
echo -e "${CYAN}### Step 1: Updating and Upgrading System Packages... ###${NC}"
apt-get update
apt-get upgrade -y
apt-get install -y
apt-get clean

echo -e "${GREEN}### System Updated Successfully. ###${NC}"
echo

# --- 2. Install Essential Utilities ---
echo -e "${CYAN}### Step 2: Installing Core Utilities (sudo, git, curl, make, ufw)... ###${NC}"
apt-get install -y \
    sudo \
    git \
    curl \
    wget \
    make \
    ufw \
    nano
echo -e "${GREEN}### Core Utilities Installed Successfully. ###${NC}"
echo

# --- 3. Install Docker and Docker Compose ---
# This follows the official Docker installation guide for Debian.
echo -e "${CYAN}### Step 3: Installing Docker and Docker Compose... ###${NC}"

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo -e "${CYAN}"
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt package index again
apt-get update

# Install Docker Engine, CLI, Containerd, and Docker Compose plugin
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation by running the hello-world image
docker run hello-world
echo -e "${GREEN}### Docker and Docker Compose Installed Successfully. ###${NC}"
echo

# --- 4. Configure Firewall (UFW) ---
echo -e "${CYAN}### Step 4: Configuring Firewall (UFW)... ###${NC}"

# Allow SSH connections (so you don't lock yourself out)
ufw allow OpenSSH
# Or use the port number directly: ufw allow 22/tcp

# Allow HTTP and HTTPS traffic for the web server
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS

# Enable the firewall (the 'yes' pipe automatically confirms the prompt)
yes | ufw enable

# Display the status of the firewall
ufw status verbose
echo -e "${GREEN}### Firewall Configured and Enabled. ###${NC}"
echo

# --- Final Message ---
echo "======================================================"
echo "    ✅ Initial server setup is complete! ✅"
echo "======================================================"
echo
echo "What's next?"
echo "1. Clone your 'inception' repository from your VCS."
echo "2. Navigate into your project directory: cd inception"
echo "3. Configure your .env file with your domain and secrets."
echo "4. Run your containers: docker-compose up --build -d"
echo
