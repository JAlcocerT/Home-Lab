1. Get **AppImage launcher** to use appimages as you download them.

```sh
#flatpak install flathub it.mijorus.gearlever
sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt update

sudo apt install appimagelauncher
mkdir ~/Applications #place your *.AppImages there and they will integrate with your linux!
```

> Examples at `hoppscotch` or `Sonixd` or `Logseq`

> > See gearlevel in case that one fails

2. Docker and other goodies to get going    

```sh
sudo apt install git
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
# Add to current path for immediate use:
export PATH="$HOME/.local/bin:$PATH"

# Docker Permissions Fix (Avoid using sudo)
# By default, docker requires root. To run it as your user:
sudo usermod -aG docker $USER
newgrp docker # Apply group changes without logging out

lazydocker --version
#sudo docker system df

###for antigravity###
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg
  
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
  sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

sudo apt update
sudo apt install antigravity
###

# Multimedia & Professional Players (Required for GoPro/DJI)
sudo apt update && sudo apt install -y vlc mpv ubuntu-restricted-extras libavcodec-extra gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav
# Reset video cache if errors persist:
rm -rf ~/.cache/gstreamer-1.0


#https://protonvpn.com/support/official-linux-vpn-debian/
#https://repo.protonvpn.com/debian/dists/stable/main/binary-amd64/
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
#echo "0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180 protonvpn-stable-release_1.0.8_all.deb" | sha256sum --check -
sudo apt install proton-vpn-gnome-desktop

###review the script first###
#sudo ./z-desktop-x-homelab/Linux_Setup_101.sh

# 3. Virtual Machines (GNOME Boxes)
# A simple way to try out other OSs
sudo apt install gnome-boxes
# To allow USB redirection:
sudo usermod -aG kvm $USER
# You may need to relogin for group changes to take effect
```