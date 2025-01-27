#!/bin/bash
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd $REAL_USER | cut -d: -f6)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
WALLPAPER_DIR="${REAL_HOME}/Wallpapers"

sudo apt update
sudo apt install -y gnome gdm3 gnome-shell gnome-shell-extensions gnome-tweaks dconf-cli plank unzip gnome-shell-extension-manager

sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.themes
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.icons/{cursors,default}
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.icons/Candy-icons
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.local/share/plank/themes
sudo -u $REAL_USER mkdir -p ${WALLPAPER_DIR}
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.config/autostart
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.config/plank/dock1

cd "${SCRIPT_DIR}"
tar xf M200.tar.gz -C ${REAL_HOME}/.icons/
tar xf candy-icons.tar.xz -C ${REAL_HOME}/.icons/
ln -sf ${REAL_HOME}/.icons/M200/index.theme ${REAL_HOME}/.icons/default/index.theme
sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme ${REAL_HOME}/.icons/M200/index.theme 20
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.icons/{M200,Candy-icons,default}

cd "${SCRIPT_DIR}"
TMP_DIR=$(mktemp -d)
unzip -o Tokyonight-Dark-BL-GS.zip -d "$TMP_DIR"

sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.themes/Tokyonight-Dark-BL-GS
mv "$TMP_DIR/gnome-shell" ${REAL_HOME}/.themes/Tokyonight-Dark-BL-GS/
rm -rf "$TMP_DIR"
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.themes/Tokyonight-Dark-BL-GS

cd "${SCRIPT_DIR}"
unzip -o Catppuccin-Mocha-B.zip -d ${REAL_HOME}/.local/share/plank/themes/
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.local/share/plank/themes/Catppuccin-Mocha-B

cd "${SCRIPT_DIR}"
cp wallpaper_* "${WALLPAPER_DIR}/"
chown -R $REAL_USER:$REAL_USER "${WALLPAPER_DIR}"

cat > "${WALLPAPER_DIR}/wallpaper-slideshow.xml" << EOL
<background>
  <starttime>
    <year>2024</year>
    <month>01</month>
    <day>24</day>
    <hour>00</hour>
    <minute>00</minute>
    <second>00</second>
  </starttime>
$(for i in {0..9}; do
  next=$((($i + 1) % 10))
  ext_current=$(ls ${WALLPAPER_DIR}/wallpaper_$i.* | grep -o '\.[^.]*$')
  ext_next=$(ls ${WALLPAPER_DIR}/wallpaper_$next.* | grep -o '\.[^.]*$')
  echo "  <static>"
  echo "    <duration>1795.0</duration>"
  echo "    <file>${WALLPAPER_DIR}/wallpaper_$i$ext_current</file>"
  echo "  </static>"
  echo "  <transition>"
  echo "    <duration>5.0</duration>"
  echo "    <from>${WALLPAPER_DIR}/wallpaper_$i$ext_current</from>"
  echo "    <to>${WALLPAPER_DIR}/wallpaper_$next$ext_next</to>"
  echo "  </transition>"
done)
</background>
EOL
chown $REAL_USER:$REAL_USER "${WALLPAPER_DIR}/wallpaper-slideshow.xml"

cat > ${REAL_HOME}/.config/autostart/theme-setup.sh << 'EOL'
#!/bin/bash
sleep 10
gsettings set org.gnome.shell.extensions.user-theme name 'Tokyonight-Dark-BL-GS'
gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark-BL-GS'
gsettings set org.gnome.desktop.interface icon-theme 'candy-icons'
gsettings set org.gnome.desktop.interface cursor-theme 'M200'
gsettings set org.gnome.desktop.background picture-uri "file://${HOME}/Wallpapers/wallpaper-slideshow.xml"
gsettings set org.gnome.desktop.background picture-uri-dark "file://${HOME}/Wallpapers/wallpaper-slideshow.xml"
gsettings set org.gnome.desktop.background picture-options 'zoom'
EOL
chmod +x ${REAL_HOME}/.config/autostart/theme-setup.sh
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/theme-setup.sh

echo "Enabling user-theme extension"
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

cat > ${REAL_HOME}/.config/autostart/theme-setup.desktop << EOL
[Desktop Entry]
Type=Application
Name=Theme Setup
Exec=${REAL_HOME}/.config/autostart/theme-setup.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/theme-setup.desktop

echo "Setting up Plank..."
cat > ${REAL_HOME}/.config/autostart/plank.desktop << EOL
[Desktop Entry]
Type=Application
Name=Plank
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/plank.desktop

sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.config/plank/dock1
killall plank 2>/dev/null || true
sleep 2
cat > ${REAL_HOME}/.config/plank/dock1/settings << EOL
[PlankDockPreferences]
#This file auto-generated by Plank.
#2024-01-24T12:00:00+0000

alignment=center
auto-pinning=true
current-workspace-only=false
dock-items=
dock-mode=0
hide-delay=0
hide-mode=0
icon-size=48
items-alignment=center
lock-items=false
monitor=-1
offset=0
pinned-only=false
position=bottom
pressure-reveal=false
show-dock-item=false
theme=Catppuccin-Mocha-B
tooltips-enabled=true
unhide-delay=0
zoom-enabled=true
zoom-percent=150
EOL
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.config/plank

cat > ${REAL_HOME}/.config/autostart/plank-setup.sh << 'EOL'
#!/bin/bash
sleep 5
killall plank 2>/dev/null || true
sleep 2
dconf write /net/launchpad/plank/docks/dock1/theme "'Catppuccin-Mocha-B'"
dconf write /net/launchpad/plank/docks/dock1/zoom-enabled "true"
dconf write /net/launchpad/plank/docks/dock1/zoom-percent "150"
plank &
EOL
chmod +x ${REAL_HOME}/.config/autostart/plank-setup.sh
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/plank-setup.sh

cat > ${REAL_HOME}/.config/autostart/plank.desktop << EOL
[Desktop Entry]
Type=Application
Name=Plank Setup
Exec=${REAL_HOME}/.config/autostart/plank-setup.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/plank.desktop

# Configurar Plank
cat > ${REAL_HOME}/.config/plank/dock1/settings << EOL
[PlankDockPreferences]
Theme=Catppuccin-Mocha-B
ZoomEnabled=true
ZoomPercent=150
EOL
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.config/plank

echo "Configuration complete. Please, make sure to:"
echo "1. Close the session and restart to apply the changes"
echo "2. If the theme does not apply automatically, you can apply it manually using GNOME Tweaks"

read -p "¿Do you want to close the session now to apply the changes? (y/n): " answer
case $answer in
    [Yy]* ) pkill -KILL -u $REAL_USER;;
    [Nn]* ) echo "Remember to close the session manually to see the changes.";;
    * ) echo "Please respond y/n";;
esac
