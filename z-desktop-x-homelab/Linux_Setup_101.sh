#!/bin/sh

# ============================================================
# Linux Setup Script for Home-Lab / Desktop
# ============================================================
# Usage: sudo ./Linux_Setup_101.sh
# ============================================================

PYTHON_VERSION="3.12"

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root (use sudo)." 1>&2
   exit 1
fi

# --- Helper Function: Yes/No Prompt ---
prompt_yes_no() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# ============================================================
# AUTOMATIC UPDATES
# ============================================================
echo "-------------------------------------------"
echo "Setting up automatic security updates..."
echo "-------------------------------------------"
apt-get update
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

# ============================================================
# DNS CONFIGURATION (Quad9 - Privacy Focused)
# ============================================================
configure_dns() {
    echo "-------------------------------------------"
    echo "Configuring DNS to Quad9 (Privacy-focused)..."
    echo "-------------------------------------------"
    
    # Get the primary network interface
    interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -z "$interface" ]; then
        echo "Could not detect network interface. Skipping DNS configuration."
        return 1
    fi
    
    echo "Detected interface: $interface"
    echo "Current DNS settings:"
    resolvectl status "$interface" 2>/dev/null || cat /etc/resolv.conf
    
    echo ""
    echo "Changing DNS to Quad9 (9.9.9.9, 149.112.112.112)..."
    resolvectl dns "$interface" 9.9.9.9 149.112.112.112
    
    echo "Updated DNS settings:"
    resolvectl status "$interface" | grep -A2 "DNS Servers"
}

# ============================================================
# DOCKER INSTALLATION
# ============================================================
install_docker() {
    echo "-------------------------------------------"
    echo "Updating system and installing Docker..."
    echo "-------------------------------------------"
    apt-get update && apt-get upgrade -y

    echo "Downloading official Docker installation script..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh

    echo "Docker installed. Version:"
    docker version

    echo "Testing Docker with 'hello-world'..."
    docker run --rm hello-world

    echo "Installing Docker Compose Plugin..."
    apt-get install -y docker-compose-plugin

    echo "Docker Compose version:"
    docker compose version

    echo "Docker service status:"
    systemctl status docker --no-pager | grep "Active"
}

install_portainer() {
    echo "-------------------------------------------"
    echo "Installing Portainer (Docker Web UI)..."
    echo "-------------------------------------------"
    docker run -d \
      -p 8000:8000 \
      -p 9443:9443 \
      --name=portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest
    echo "Portainer is running at https://localhost:9443"
}

# ============================================================
# PODMAN INSTALLATION
# ============================================================
install_podman() {
    echo "-------------------------------------------"
    echo "Installing Podman OCI..."
    echo "-------------------------------------------"
    apt-get install -y podman
    podman --version
}

# ============================================================
# PYTHON VERSION MANAGEMENT
# ============================================================
install_python() {
    echo "-------------------------------------------"
    echo "Installing Python $PYTHON_VERSION via deadsnakes PPA..."
    echo "-------------------------------------------"
    
    # Add deadsnakes PPA for latest Python versions
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:deadsnakes/ppa
    apt-get update
    
    # Install Python with common packages
    apt-get install -y "python$PYTHON_VERSION" "python$PYTHON_VERSION-venv" "python$PYTHON_VERSION-dev"
    
    echo "Python $PYTHON_VERSION installed:"
    "python$PYTHON_VERSION" --version
    
    # Set as default (optional)
    if prompt_yes_no "Do you want to set Python $PYTHON_VERSION as the default 'python3'?;"; then
        update-alternatives --install /usr/bin/python3 python3 "/usr/bin/python$PYTHON_VERSION" 1
        echo "Python $PYTHON_VERSION is now the default python3."
        python3 --version
    fi
}

# ============================================================
# UV PACKAGE MANAGER (Astral)
# ============================================================
install_uv() {
    echo "-------------------------------------------"
    echo "Installing uv (Ultra-fast Python package manager)..."
    echo "  -> From Astral (creators of Ruff)"
    echo "  -> 10-100x faster than pip"
    echo "  -> Drop-in replacement for pip, venv, pyenv"
    echo "-------------------------------------------"
    
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add to PATH for current session and permanent
    export PATH="$HOME/.local/bin:$PATH"
    if ! grep -q ".local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo "Added uv to PATH in ~/.bashrc"
    fi
    
    echo "uv installed:"
    "$HOME/.local/bin/uv" --version || uv --version
}

# ============================================================
# TAILSCALE VPN
# ============================================================
install_tailscale() {
    echo "-------------------------------------------"
    echo "Installing Tailscale VPN..."
    echo "-------------------------------------------"
    curl -fsSL https://tailscale.com/install.sh | sh
    
    if prompt_yes_no "Do you want to activate Tailscale now?"; then
        echo "Starting Tailscale authentication..."
        tailscale up
        
        echo "Tailscale activated!"
        ip_address=$(tailscale ip -4 2>/dev/null)
        if [ -n "$ip_address" ]; then
            echo "Your Tailscale IP address is: $ip_address"
        fi
    else
        echo "Run 'sudo tailscale up' later to activate."
    fi
}

# ============================================================
# MAIN MENU
# ============================================================

# --- DNS Configuration ---
if prompt_yes_no "Do you want to configure DNS to Quad9 (privacy-focused)?"; then
    configure_dns
else
    echo "DNS configuration skipped."
fi

# --- Docker ---
if prompt_yes_no "Do you want to install DOCKER?"; then
    install_docker

    # --- Portainer (Optional) ---
    if prompt_yes_no "Do you want to install PORTAINER (Docker Web UI)?"; then
        install_portainer
    else
        echo "Portainer installation skipped."
    fi
else
    echo "Docker installation skipped."
fi

# --- Podman ---
if prompt_yes_no "Do you want to install PODMAN?"; then
    install_podman
else
    echo "Podman installation skipped."
fi

# --- Python 3.12 ---
if prompt_yes_no "Do you want to install Python 3.12 (via deadsnakes PPA)?"; then
    install_python
else
    echo "Python 3.12 installation skipped."
fi

# --- uv Package Manager ---
if prompt_yes_no "Do you want to install uv (ultra-fast Python package manager)?"; then
    install_uv
else
    echo "uv installation skipped."
fi

# --- Desktop Apps (Flatpak/Snap) ---
if prompt_yes_no "Do you want to install desktop apps (VSCodium, LibreWolf, Brave)?"; then
    echo "Installing VSCodium via Snap..."
    snap install codium --classic
    
    echo "Installing VSCodium extensions..."
    codium --install-extension unifiedjs.vscode-mdx
    codium --install-extension astro-build.astro-vscode
    codium --install-extension ms-python.python
    codium --install-extension gitlab.gitlab-workflow

    echo "Installing Brave Browser via native repository..."
    apt-get install -y curl
    rm -f /etc/apt/sources.list.d/brave-browser-release.list
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    apt-get update
    apt-get install -y brave-browser

    echo "Installing LibreWolf and Zen Browser via Flatpak..."
    flatpak install -y flathub io.gitlab.librewolf-community
    flatpak install -y flathub app.zen_browser.zen

    echo "Installed Snap packages:"
    snap list
    echo "Installed Flatpak packages:"
    flatpak list
else
    echo "Desktop apps installation skipped."
fi

# --- Video Tools ---
if prompt_yes_no "Do you want to install video tools (OBS Studio)?"; then
    echo "Installing OBS Studio..."
    flatpak install -y flathub com.obsproject.Studio
else
    echo "Video tools installation skipped."
fi

# --- Bitwarden ---
if prompt_yes_no "Do you want to install Bitwarden?"; then
    echo "Installing Bitwarden..."
    snap install bitwarden
else
    echo "Bitwarden installation skipped."
fi

# --- Tailscale VPN ---
if prompt_yes_no "Do you want to install Tailscale VPN?"; then
    install_tailscale
else
    echo "Tailscale VPN installation skipped."
fi

# --- Package Manager Utilities ---
if prompt_yes_no "Do you want to install package manager utilities (Nala + Synaptic)?"; then
    echo "-------------------------------------------"
    echo "Installing Package Manager Utilities..."
    echo "-------------------------------------------"
    
    echo ""
    echo "Installing Nala..."
    echo "  -> A modern CLI replacement for 'apt'"
    echo "  -> Parallel downloads, clean tables, undo history"
    echo "  -> Use: 'sudo nala install <package>'"
    apt-get install -y nala
    
    echo ""
    echo "Installing Synaptic..."
    echo "  -> A graphical GUI for managing APT packages"
    echo "  -> Search, install, remove packages visually"
    echo "  -> Launch from your app menu or run: 'sudo synaptic'"
    apt-get install -y synaptic
    
    echo "Package manager utilities installed!"
else
    echo "Package manager utilities installation skipped."
fi

echo "-------------------------------------------"
echo "Setup complete!"
echo "-------------------------------------------"