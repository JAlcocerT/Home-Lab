#!/bin/bash

set -euo pipefail

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Determine the non-root user to configure
if [ -n "${SUDO_USER:-}" ]; then
    TARGET_USER="$SUDO_USER"
else
    log "SUDO_USER is unset. Enter the non-root username to configure:"
    read -r TARGET_USER
    if ! id "$TARGET_USER" >/dev/null 2>&1; then
        log "Error: user '$TARGET_USER' does not exist. Exiting."
        exit 1
    fi
fi
log "Target user: $TARGET_USER"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

log "Adding automatic updates..."
apt-get update -qq
apt-get install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades


### BETTER DNS ###

if command_exists resolvectl; then
    log "Configuring DNS with resolvectl..."
    interface=$(resolvectl status | grep -A 1 'Link 2' | awk -F '[()]' '/Link 2/{print $2}' || echo "")

    if [ -n "$interface" ]; then
        log "Initial DNS settings for interface: $interface"
        resolvectl status "$interface"

        log "Changing DNS to Quad9 (9.9.9.9, 149.112.112.112)..."
        resolvectl dns "$interface" 9.9.9.9 149.112.112.112

        log "Updated DNS settings:"
        resolvectl status "$interface"
        resolvectl status | grep 'DNS Servers'
    else
        log "Warning: could not determine active interface, skipping DNS configuration"
    fi
else
    log "Warning: resolvectl not found, skipping DNS configuration"
fi


### CONTAINERS SETUP ###

install_docker() {
    log "Installing Docker via official apt repository..."
    apt-get install -y ca-certificates curl gnupg

    install -m 0755 -d /etc/apt/keyrings
    . /etc/os-release
    curl -fsSL "https://download.docker.com/linux/${ID}/gpg" \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -qq
    apt-get install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    if ! command_exists docker; then
        log "Error: Docker installation failed"
        return 1
    fi
    log "Docker installed: $(docker --version)"

    if ! systemctl is-active --quiet docker; then
        log "Starting Docker service..."
        systemctl start docker
    fi

    if docker compose version >/dev/null 2>&1; then
        log "Docker Compose plugin: $(docker compose version --short)"
    else
        log "Warning: Docker Compose plugin not detected"
    fi

    log "Testing Docker with hello-world..."
    if ! timeout 30 docker run --rm hello-world >/dev/null 2>&1; then
        log "Warning: hello-world test failed (network?), continuing"
    else
        log "Docker test passed"
    fi
}

install_portainer() {
    log "Starting Portainer (bound to 127.0.0.1 only)..."
    docker run -d \
        -p 127.0.0.1:8000:8000 \
        -p 127.0.0.1:9000:9000 \
        --name=portainer --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce \
        || log "Warning: Portainer launch failed (already running?)"
    log "Portainer: http://127.0.0.1:9000 — localhost only."
    log "Remote access via SSH tunnel: ssh -L 9000:127.0.0.1:9000 user@host"
}

install_podman() {
    log "Installing Podman OCI..."
    apt-get install -y podman

    if command_exists podman; then
        log "Podman installed: $(podman --version)"
    else
        log "Error: Podman installation failed"
        return 1
    fi
}

log "Do you want to install Docker on your system? (yes/no)"
read -r install_docker_answer
case $install_docker_answer in
    [yY] | [yY][eE][sS])
        install_docker || { log "Error: Docker installation failed"; exit 1; }
        install_podman || log "Warning: Podman installation failed, continuing"

        log "Do you want to install Portainer (Docker web UI)? (yes/no)"
        read -r install_portainer_answer
        case $install_portainer_answer in
            [yY] | [yY][eE][sS])
                install_portainer || log "Warning: Portainer launch failed, continuing"
                ;;
            [nN] | [nN][oO])
                log "Portainer installation skipped."
                ;;
            *)
                log "Invalid response. Skipping Portainer."
                ;;
        esac
        ;;
    [nN] | [nN][oO])
        log "Container installation skipped."
        ;;
    *)
        log "Invalid response. Exiting."
        exit 1
        ;;
esac


### TAILSCALE VPN ###

install_tailscale() {
    log "Installing Tailscale via official apt repository..."
    apt-get install -y curl gnupg

    . /etc/os-release
    curl -fsSL "https://pkgs.tailscale.com/stable/${ID}/${VERSION_CODENAME}.noarmor.gpg" \
        | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] \
https://pkgs.tailscale.com/stable/${ID} ${VERSION_CODENAME} main" \
        | tee /etc/apt/sources.list.d/tailscale.list

    apt-get update -qq
    apt-get install -y tailscale

    if ! command_exists tailscale; then
        log "Error: tailscale not found after installation"
        return 1
    fi

    log "Bringing Tailscale up (auth in browser if prompted)..."
    tailscale up || log "Warning: 'tailscale up' returned non-zero (manual auth may be needed)"

    if tailscale status >/dev/null 2>&1; then
        ip_address=$(tailscale ip -4 2>/dev/null || echo "not assigned yet")
        log "Tailscale IP: $ip_address"
    fi
}

log "Do you want to install Tailscale VPN on your system? (yes/no)"
read -r install_tailscale_answer
case $install_tailscale_answer in
    [yY] | [yY][eE][sS])
        install_tailscale || { log "Error: Tailscale installation failed"; exit 1; }
        ;;
    [nN] | [nN][oO])
        log "Tailscale VPN installation skipped."
        ;;
    *)
        log "Invalid response. Exiting."
        exit 1
        ;;
esac


### SHELL ALIASES ###

setup_aliases() {
    local BASHRC="${TARGET_HOME}/.bashrc"

    if [ ! -f "$BASHRC" ]; then
        log "Warning: $BASHRC not found, skipping aliases."
        return 1
    fi

    log "Adding shell aliases to $BASHRC..."

    if grep -q "# === homelab aliases ===" "$BASHRC"; then
        log "Aliases already present in $BASHRC. Skipping."
        return
    fi

    cat >> "$BASHRC" <<'EOF'

# === homelab aliases ===

# ls shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# git: stage all, commit with message, and push
gcp() {
  if [ -z "$1" ]; then
    echo 'Usage: gcp "commit message"'
    return 1
  fi
  git add -A && git commit -m "$1" && git push
}

# alert: notify when a long-running command finishes
# Usage: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# docker compose shortcuts
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
EOF

    echo ""
    log "Aliases added to $BASHRC. Run 'source $BASHRC' or open a new terminal to apply."
    echo ""
    echo "Available aliases:"
    echo "  ll / la / l   -- ls variants"
    echo "  gcp \"msg\"     -- git add -A && commit && push"
    echo "  alert         -- desktop notification when a long command finishes"
    echo "  dcu           -- docker compose up -d"
    echo "  dcd           -- docker compose down"
    echo "  dcl           -- docker compose logs -f"
}

log "Do you want to set up shell aliases (ll, la, l, gcp, alert, dcu, dcd, dcl)? (yes/no)"
read -r setup_aliases_answer
case $setup_aliases_answer in
    [yY] | [yY][eE][sS])
        setup_aliases
        ;;
    [nN] | [nN][oO])
        log "Alias setup skipped."
        ;;
    *)
        log "Invalid response. Exiting."
        exit 1
        ;;
esac


### SECURITY HARDENING ###

harden_firewall() {
    log "Installing UFW..."
    apt-get install -y ufw

    if ufw status | grep -q "Status: active"; then
        log "WARNING: UFW is already active with existing rules:"
        ufw status numbered
        log "Existing rules will be preserved. Adding defaults and SSH rule only."
    fi

    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp comment 'SSH'
    ufw --force enable
    ufw status verbose
    log "Note: Docker-published ports bypass UFW via iptables. Bind services to 127.0.0.1 to keep them local-only."
}

harden_fail2ban() {
    log "Installing fail2ban..."
    apt-get install -y fail2ban
    cat > /etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled = true
port    = ssh
maxretry = 4
bantime  = 1h
findtime = 10m
EOF
    systemctl enable --now fail2ban
    systemctl restart fail2ban
}

harden_ssh() {
    log "Hardening SSH config..."
    SSHD=/etc/ssh/sshd_config
    cp -n "$SSHD" "${SSHD}.bak.$(date +%s)"

    set_sshd() {
        key="$1"; val="$2"
        if grep -qE "^\s*#?\s*${key}\b" "$SSHD"; then
            sed -i -E "s|^\s*#?\s*${key}\b.*|${key} ${val}|" "$SSHD"
        else
            echo "${key} ${val}" >> "$SSHD"
        fi
    }

    set_sshd PermitRootLogin no
    set_sshd PubkeyAuthentication yes
    set_sshd X11Forwarding no
    set_sshd ChallengeResponseAuthentication no
    set_sshd KbdInteractiveAuthentication no

    auth_keys="${TARGET_HOME}/.ssh/authorized_keys"
    if [ -s "$auth_keys" ]; then
        log "Authorized key found for ${TARGET_USER}. Disabling password auth."
        set_sshd PasswordAuthentication no
    else
        log "WARNING: no authorized_keys for ${TARGET_USER} at ${auth_keys}."
        log "Leaving PasswordAuthentication enabled to prevent lockout."
        log "Add a key, then run: sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' ${SSHD} && systemctl reload ssh"
    fi

    if ! sshd -t; then
        log "Error: sshd config test failed. Restoring backup."
        latest_bak=$(ls -t "${SSHD}.bak."* 2>/dev/null | head -1)
        [ -n "$latest_bak" ] && cp "$latest_bak" "$SSHD"
        return 1
    fi
    systemctl reload ssh
}

harden_sysctl() {
    log "Applying kernel sysctl hardening..."
    cat > /etc/sysctl.d/99-hardening.conf <<'EOF'
# Network
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
# Kernel
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 2
kernel.sysrq = 0
EOF
    sysctl --system
}

harden_tmp_noexec() {
    log "Setting noexec on /tmp..."
    log "Note: noexec on /tmp can break some installers and build tools on low-memory systems."

    if grep -qE '^\s*tmpfs\s+/tmp\s.*noexec' /etc/fstab; then
        log "/tmp already has noexec in fstab, skipping."
        return 0
    fi

    if grep -qE '^\s*tmpfs\s+/tmp\s' /etc/fstab; then
        awk '/^\s*tmpfs\s+\/tmp\s/ { if ($4 !~ /noexec/) $4 = $4 ",noexec" } { print }' \
            /etc/fstab > /etc/fstab.tmp && mv /etc/fstab.tmp /etc/fstab
    else
        echo 'tmpfs /tmp tmpfs rw,nosuid,nodev,noexec 0 0' >> /etc/fstab
    fi
    log "Reboot or 'mount -o remount /tmp' to apply."
}

harden_journald() {
    log "Limiting journald size..."
    sed -i -E 's|^#?SystemMaxUse=.*|SystemMaxUse=100M|' /etc/systemd/journald.conf
    grep -q '^SystemMaxUse=' /etc/systemd/journald.conf || echo 'SystemMaxUse=100M' >> /etc/systemd/journald.conf
    systemctl restart systemd-journald
}

harden_cron() {
    log "Restricting cron..."
    { echo "root"; echo "$TARGET_USER"; } > /etc/cron.allow
    chmod 644 /etc/cron.allow
}

harden_pwquality() {
    log "Installing libpam-pwquality..."
    apt-get install -y libpam-pwquality
    sed -i -E 's|^#?\s*minlen\s*=.*|minlen = 12|' /etc/security/pwquality.conf 2>/dev/null || true
    sed -i -E 's|^#?\s*retry\s*=.*|retry = 3|' /etc/security/pwquality.conf 2>/dev/null || true
}

harden_auditd() {
    log "Installing auditd..."
    apt-get install -y auditd audispd-plugins
    systemctl enable --now auditd
}

harden_docker_logs() {
    if ! command_exists docker; then
        log "Docker not installed, skipping log caps."
        return 0
    fi

    local daemon_json=/etc/docker/daemon.json
    mkdir -p /etc/docker

    if [ -f "$daemon_json" ]; then
        cp -n "$daemon_json" "${daemon_json}.bak.$(date +%s)"
        if command_exists jq; then
            log "Merging log caps into existing $daemon_json..."
            tmp=$(mktemp)
            jq '. + {
                "log-driver": "json-file",
                "log-opts": { "max-size": "10m", "max-file": "3" },
                "live-restore": true
            }' "$daemon_json" > "$tmp" && mv "$tmp" "$daemon_json"
        else
            log "Warning: jq not found. $daemon_json exists; skipping merge to avoid clobber."
            log "Install jq (apt-get install -y jq) and re-run, or edit manually."
            return 0
        fi
    else
        log "Writing fresh $daemon_json with log caps..."
        cat > "$daemon_json" <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true
}
EOF
    fi

    chmod 644 "$daemon_json"

    if command_exists python3; then
        if ! python3 -c "import json; json.load(open('$daemon_json'))" 2>/dev/null; then
            log "Error: $daemon_json invalid JSON. Restoring backup."
            latest_bak=$(ls -t "${daemon_json}.bak."* 2>/dev/null | head -1)
            [ -n "$latest_bak" ] && mv "$latest_bak" "$daemon_json" || true
            return 1
        fi
    fi

    if systemctl is-active --quiet docker; then
        log "Restarting Docker to apply log caps..."
        systemctl restart docker
    fi

    log "Note: log caps apply to NEW containers. Recreate existing ones to take effect:"
    log "  cd <compose-dir> && docker compose up -d --force-recreate"
}

harden_docker_isolation() {
    if ! command_exists docker; then
        log "Docker not installed, skipping isolation hardening."
        return 0
    fi

    if ! command_exists jq; then
        log "Error: jq required for safe daemon.json merge. Aborting isolation step."
        return 1
    fi

    local daemon_json=/etc/docker/daemon.json
    mkdir -p /etc/docker
    [ -f "$daemon_json" ] || echo '{}' > "$daemon_json"
    cp -n "$daemon_json" "${daemon_json}.bak.$(date +%s)"

    apply_jq() {
        local expr="$1"
        local tmp
        tmp=$(mktemp)
        jq "$expr" "$daemon_json" > "$tmp" && mv "$tmp" "$daemon_json"
    }

    log "Enable 'no-new-privileges' (blocks setuid escalation in containers)? Risk: NONE for typical workloads. (yes/no)"
    read -r nnp_answer
    case $nnp_answer in
        [yY]|[yY][eE][sS])
            apply_jq '. + {"no-new-privileges": true}'
            log "no-new-privileges enabled."
            ;;
        *) log "no-new-privileges skipped." ;;
    esac

    log "Disable inter-container communication on default bridge ('icc: false')? Risk: containers on default bridge stop talking. Mitigation: use per-stack networks. (yes/no)"
    read -r icc_answer
    case $icc_answer in
        [yY]|[yY][eE][sS])
            apply_jq '. + {"icc": false}'
            log "icc=false applied. Remember: per-stack networks required."
            ;;
        *) log "icc left at default (true)." ;;
    esac

    log "Enable userns-remap? Risk: HIGH on existing systems — volumes need chown. Recommended ONLY for fresh installs. (yes/no)"
    read -r userns_answer
    case $userns_answer in
        [yY]|[yY][eE][sS])
            apply_jq '. + {"userns-remap": "default"}'
            log "userns-remap=default applied. WARNING: existing volumes may be inaccessible until chowned to dockremap UID."
            ;;
        *) log "userns-remap skipped." ;;
    esac

    chmod 644 "$daemon_json"

    if command_exists python3; then
        if ! python3 -c "import json; json.load(open('$daemon_json'))" 2>/dev/null; then
            log "Error: $daemon_json invalid JSON. Restoring backup."
            latest_bak=$(ls -t "${daemon_json}.bak."* 2>/dev/null | head -1)
            [ -n "$latest_bak" ] && mv "$latest_bak" "$daemon_json" || true
            return 1
        fi
    fi

    if systemctl is-active --quiet docker; then
        log "Restarting Docker to apply isolation flags..."
        systemctl restart docker
    fi

    log "Final daemon.json:"
    cat "$daemon_json"
}

harden_logrotate() {
    apt-get install -y logrotate
    if [ -f /etc/logrotate.d/rsyslog ]; then
        log "logrotate rsyslog config present (defaults are sane)."
    fi
    logrotate -f /etc/logrotate.conf || log "Warning: logrotate run returned non-zero"
}

harden_bluetooth() {
    log "Disabling Bluetooth via boot overlay..."
    for cfg in /boot/firmware/config.txt /boot/config.txt; do
        if [ -f "$cfg" ]; then
            grep -q '^dtoverlay=disable-bt' "$cfg" || echo 'dtoverlay=disable-bt' >> "$cfg"
            log "Updated $cfg"
        fi
    done
    systemctl disable --now bluetooth.service hciuart.service 2>/dev/null || true
}

preflight_check() {
    log "=== PREFLIGHT SUMMARY ==="
    echo ""
    echo "System : $(. /etc/os-release && echo "$PRETTY_NAME")"
    echo "User   : $TARGET_USER (home: $TARGET_HOME)"
    echo ""

    # Firewall
    if command_exists ufw && ufw status | grep -q "Status: active"; then
        rule_count=$(ufw status numbered 2>/dev/null | grep -c '^\[' || echo 0)
        echo "Firewall  : UFW active, $rule_count rule(s) — existing rules will be PRESERVED"
    else
        echo "Firewall  : UFW not active"
    fi

    # SSH
    pw_auth=$(grep -E '^\s*PasswordAuthentication\s' /etc/ssh/sshd_config 2>/dev/null \
        | awk '{print $2}' | tail -1 || echo "default(yes)")
    echo "SSH passwd: PasswordAuthentication = ${pw_auth}"
    auth_keys="${TARGET_HOME}/.ssh/authorized_keys"
    if [ -s "$auth_keys" ]; then
        key_count=$(grep -cE '^(ssh-|ecdsa-|sk-)' "$auth_keys" 2>/dev/null || echo "?")
        echo "SSH keys  : $key_count key(s) for $TARGET_USER — safe to disable password auth"
    else
        echo "SSH keys  : NONE for $TARGET_USER — password auth will NOT be disabled (lockout prevention)"
    fi

    # /tmp
    if grep -qE '^\s*tmpfs\s+/tmp\s.*noexec' /etc/fstab 2>/dev/null; then
        echo "/tmp noexec: already set"
    else
        mem_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
        warn=""
        [ "$mem_mb" -lt 512 ] && warn=" — WARNING: low memory (${mem_mb}MB), tmpfs may cause OOM"
        echo "/tmp noexec: not set — can break build tools and installers${warn}"
    fi

    # Docker
    if command_exists docker; then
        running=$(docker ps -q 2>/dev/null | wc -l)
        daemon_note="no daemon.json"
        [ -f /etc/docker/daemon.json ] && daemon_note="daemon.json exists (jq merge)"
        echo "Docker    : $(docker --version | awk '{print $3}' | tr -d ','), $running running container(s), $daemon_note"
    else
        echo "Docker    : not installed — Docker hardening will be skipped"
    fi

    # Cron
    if [ -f /etc/cron.allow ]; then
        current=$(tr '\n' ' ' < /etc/cron.allow)
        echo "Cron allow: already set ($current)"
    else
        echo "Cron allow: not set — will restrict to root + $TARGET_USER only"
    fi

    echo ""
    log "==========================="
    echo ""
}

apply_hardening() {
    preflight_check

    log "Proceed with hardening? (yes/no)"
    read -r proceed
    case $proceed in
        [yY]|[yY][eE][sS]) ;;
        *) log "Hardening cancelled."; return 0 ;;
    esac

    # Safe steps — no individual prompts
    harden_fail2ban
    harden_sysctl
    harden_journald
    harden_logrotate
    harden_pwquality
    harden_auditd

    # Risky: firewall
    log "Configure UFW (deny incoming, allow outgoing, keep SSH open)? (yes/no)"
    read -r fw_answer
    case $fw_answer in
        [yY]|[yY][eE][sS]) harden_firewall ;;
        *) log "Firewall skipped." ;;
    esac

    # Risky: SSH
    log "Harden SSH (PermitRootLogin no, disable password auth if keys exist)? (yes/no)"
    read -r ssh_answer
    case $ssh_answer in
        [yY]|[yY][eE][sS]) harden_ssh ;;
        *) log "SSH hardening skipped." ;;
    esac

    # Risky: /tmp noexec
    log "Mount /tmp as noexec? Can break build tools and some installers. (yes/no)"
    read -r tmp_answer
    case $tmp_answer in
        [yY]|[yY][eE][sS]) harden_tmp_noexec ;;
        *) log "/tmp noexec skipped." ;;
    esac

    # Risky: Docker daemon (jq installed once for both functions)
    log "Apply Docker daemon hardening (log caps + isolation options)? Restarts Docker. (yes/no)"
    read -r docker_harden_answer
    case $docker_harden_answer in
        [yY]|[yY][eE][sS])
            apt-get install -y jq
            harden_docker_logs
            harden_docker_isolation
            ;;
        *) log "Docker daemon hardening skipped." ;;
    esac

    # Risky: cron
    log "Restrict cron to root and $TARGET_USER only (/etc/cron.allow)? (yes/no)"
    read -r cron_answer
    case $cron_answer in
        [yY]|[yY][eE][sS]) harden_cron ;;
        *) log "Cron restriction skipped." ;;
    esac

    log "Hardening done. Reboot recommended."
}

log "Apply security hardening? (yes/no)"
read -r harden_answer
case $harden_answer in
    [yY] | [yY][eE][sS])
        apply_hardening
        ;;
    [nN] | [nN][oO])
        log "Security hardening skipped."
        ;;
    *)
        log "Invalid response. Exiting."
        exit 1
        ;;
esac


### DISABLE BLUETOOTH (RPi) ###

log "Disable Bluetooth (RPi only, edits boot overlay, requires reboot)? (yes/no)"
read -r bt_answer
case $bt_answer in
    [yY] | [yY][eE][sS])
        harden_bluetooth
        log "Bluetooth disabled. Reboot to take effect."
        ;;
    [nN] | [nN][oO])
        log "Bluetooth left untouched."
        ;;
    *)
        log "Invalid response. Exiting."
        exit 1
        ;;
esac


### INSTALLATION SUMMARY ###

log "Homelab setup complete! Installed versions:"
echo ""

if command_exists unattended-upgrade; then
    echo "✓ unattended-upgrades: $(dpkg -l | awk '/^ii  unattended-upgrades/ {print $3}')"
fi

if command_exists docker; then
    echo "✓ Docker: $(docker --version | awk '{print $3}' | sed 's/,//')"
fi

if docker compose version >/dev/null 2>&1; then
    echo "✓ Docker Compose (plugin): $(docker compose version --short)"
fi

if command_exists podman; then
    echo "✓ Podman: $(podman --version | awk '{print $3}')"
fi

if command_exists tailscale; then
    echo "✓ Tailscale: $(tailscale version | head -1)"
fi

if command_exists ufw; then
    echo "✓ UFW: $(ufw status | head -1)"
fi

if command_exists fail2ban-client; then
    echo "✓ fail2ban: $(fail2ban-client --version 2>/dev/null | head -1)"
fi

echo ""
log "Tailscale: run 'tailscale up' to authenticate if not already"
if docker ps --filter name=portainer --format '{{.Names}}' 2>/dev/null | grep -q portainer; then
    log "Portainer: http://127.0.0.1:9000 (localhost only — SSH tunnel for remote: ssh -L 9000:127.0.0.1:9000 user@host)"
fi
log "Reboot recommended to apply hardening (sysctl/tmpfs/Bluetooth)"
