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
# REPOSITORY CLEANUP
# ============================================================
echo "-------------------------------------------"
echo "Cleaning up broken/duplicate repositories..."
echo "-------------------------------------------"
# Remove duplicate Brave list (we use .sources now)
rm -f /etc/apt/sources.list.d/brave-browser-release.list
# Remove broken/deprecated AppImageLauncher PPA
if [ -f "/etc/apt/sources.list.d/appimagelauncher-team-ubuntu-stable-noble.sources" ]; then
    rm -f /etc/apt/sources.list.d/appimagelauncher-team-ubuntu-stable-noble.sources
    echo "Removed deprecated AppImageLauncher repository."
fi

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
    systemctl status docker --no-pager | grep "Active" || echo "Docker service not found"

    # Add current user to docker group to avoid needing sudo
    if [ -n "$SUDO_USER" ]; then
        groupadd -f docker
        usermod -aG docker "$SUDO_USER"
        echo "Added user $SUDO_USER to the 'docker' group."
        echo "Note: You may need to log out and back in for this to take effect."
    fi

    # Refresh shell paths
    hash -r
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
# LAZYDOCKER INSTALLATION
# ============================================================
install_lazydocker() {
    echo "-------------------------------------------"
    echo "Installing lazydocker (TUI for Docker)..."
    echo "-------------------------------------------"
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    
    # Refresh shell paths
    hash -r
    
    echo "lazydocker installed:"
    "$HOME/.local/bin/lazydocker" --version || lazydocker --version
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

    echo "--- Confirmation ---"
    python3 --version || echo "python3 not found"

    # Python to Python3 alias
    if prompt_yes_no "Do you want to alias 'python' to 'python3' for convenience?"; then
        apt-get install -y python-is-python3
        echo "Alias 'python' -> 'python3' installed."
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

    # Refresh shell paths
    hash -r
}

# ============================================================
# MULTIMEDIA CODECS
# ============================================================
install_codecs() {
    echo "-------------------------------------------"
    echo "Installing 'Nuclear' Multimedia Pack..."
    echo "-------------------------------------------"
    # Auto-accept EULA for MS fonts
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
    
    # Comprehensive GStreamer and FFmpeg pack
    apt-get install -y ubuntu-restricted-extras libavcodec-extra \
        gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav gstreamer1.0-vaapi \
        vlc mpv ffmpeg mesa-va-drivers-full
    
    echo "Setting MPV as the default player for common video formats..."
    mkdir -p ~/.config
    # Set MPV as default for MP4, MKV, MOV (GoPro/DJI often use these)
    xdg-mime default mpv.desktop video/mp4
    xdg-mime default mpv.desktop video/x-matroska
    xdg-mime default mpv.desktop video/quicktime
    
    echo "Clearing GStreamer cache..."
    rm -rf "$HOME/.cache/gstreamer-1.0"
    
    echo "Multimedia setup complete. Try opening your video now!"
}

# ============================================================
# LAZYGIT INSTALLATION
# ============================================================
install_lazygit() {
    echo "-------------------------------------------"
    echo "Installing lazygit (TUI for Git)..."
    echo "-------------------------------------------"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
    echo "lazygit installed:"
    lazygit --version
}

# ============================================================
# TELEGRAM DESKTOP INSTALLATION
# ============================================================
install_telegram() {
    echo "-------------------------------------------"
    echo "Installing Telegram Desktop via Flatpak..."
    echo "-------------------------------------------"
    flatpak install -y flathub org.telegram.desktop
    echo "Telegram Desktop installed!"
}

# ============================================================
# SIGNAL DESKTOP INSTALLATION
# ============================================================
install_signal() {
    echo "-------------------------------------------"
    echo "Installing Signal Desktop via Flatpak..."
    echo "-------------------------------------------"
    flatpak install -y flathub org.signal.Signal
    echo "Signal Desktop installed!"
}

# ============================================================
# KDENLIVE INSTALLATION
# ============================================================
install_kdenlive() {
    echo "-------------------------------------------"
    echo "Installing Kdenlive via Flatpak..."
    echo "-------------------------------------------"
    flatpak install -y flathub org.kde.kdenlive
    echo "Kdenlive installed!"
}

# ============================================================
# AUTO-CPUFREQ INSTALLATION
# ============================================================
install_auto_cpufreq() {
    echo "-------------------------------------------"
    echo "Installing auto-cpufreq (CPU Performance)..."
    echo "-------------------------------------------"
    # Dependencies
    apt-get install -y git python3-pip python3-setuptools python3-dev
    
    # Clone and install
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq || return
    ./auto-cpufreq-installer --install
    cd ..
    rm -rf auto-cpufreq
    
    echo "auto-cpufreq installed! Run 'sudo auto-cpufreq --gui' to configure."
}

# ============================================================
# MONITORING TOOLS (htop, btop)
# ============================================================
install_monitoring_tools() {
    echo "-------------------------------------------"
    echo "Installing Monitoring Tools (htop, btop)..."
    echo "-------------------------------------------"
    apt-get install -y htop btop
    echo "Monitoring tools installed!"
}

# ============================================================
# STARSHIP PROMPT
# ============================================================
install_starship() {
    echo "-------------------------------------------"
    echo "Installing Starship Prompt..."
    echo "-------------------------------------------"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    
    if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        echo "Added Starship to ~/.bashrc"
    fi
    echo "Starship installed! (Restart terminal to see effect)"
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

    # --- Lazydocker (Optional) ---
    if prompt_yes_no "Do you want to install LAZYDOCKER (TUI for Docker)?"; then
        install_lazydocker
    else
        echo "Lazydocker installation skipped."
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
    apt-get install -y brave-browser || echo "Failed to install native Brave Browser."

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

if prompt_yes_no "Do you want to install Kdenlive (Video Editor)?"; then
    install_kdenlive
else
    echo "Kdenlive installation skipped."
fi

# --- Telegram ---
if prompt_yes_no "Do you want to install Telegram Desktop?"; then
    install_telegram
else
    echo "Telegram installation skipped."
fi

if prompt_yes_no "Do you want to install Signal Desktop?"; then
    install_signal
else
    echo "Signal installation skipped."
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

# --- Multimedia Codecs ---
if prompt_yes_no "Do you want to install Multimedia Codecs (for MP4/GoPro/DJI support)?"; then
    install_codecs
    echo "Installing MPV (recommended for high-quality video playback)..."
    apt-get install -y mpv
else
    echo "Codec installation skipped."
fi

# --- Performance & Monitoring ---
if prompt_yes_no "Do you want to install auto-cpufreq (Battery/CPU optimization)?"; then
    install_auto_cpufreq
else
    echo "auto-cpufreq installation skipped."
fi

if prompt_yes_no "Do you want to install Monitoring Tools (htop, btop)?"; then
    install_monitoring_tools
else
    echo "Monitoring tools installation skipped."
fi

# --- CLI Tools (Lazygit, Starship) ---
if prompt_yes_no "Do you want to install CLI polish tools (Lazygit + Starship Prompt)?"; then
    install_lazygit
    install_starship
else
    echo "CLI polish tools skipped."
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