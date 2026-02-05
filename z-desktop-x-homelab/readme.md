1. Get **AppImage launcher** to use appimages as you download them.

```sh
sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt update

sudo apt install appimagelauncher
mkdir ~/Applications #place your *.AppImages there and they will integrate with your linux!
```

> Examples at `hoppscotch` or `Sonixd`

2. Docker and other goodies to get going    

```sh
sudo apt install git
# curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
# echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
# source ~/.bashrc
#lazydocker

###
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg
  
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
  sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

sudo apt update
sudo apt install antigravity
###

#sudo apt install ffmpeg

#https://protonvpn.com/support/official-linux-vpn-debian/
#https://repo.protonvpn.com/debian/dists/stable/main/binary-amd64/
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
#echo "0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180 protonvpn-stable-release_1.0.8_all.deb" | sha256sum --check -
sudo apt install proton-vpn-gnome-desktop
sudo ./z-desktop-x-homelab/Linux_Setup_101.sh
```