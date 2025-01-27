#!/bin/bash
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd $REAL_USER | cut -d: -f6)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
WALLPAPER_DIR="${REAL_HOME}/Wallpapers"

# Function to select cursors
select_cursors() {
    echo "Select cursor pack:"
    select cursor_pack in "M200" "Catppuccin Mocha Mauve"; do
        case $cursor_pack in
            "M200")
                CURSOR_FILE="M200.tar.gz"
                CURSOR_NAME="M200"
                break
                ;;
            "Catppuccin Mocha Mauve")
                CURSOR_FILE="catppuccin-mocha-mauve-cursors.zip"
                CURSOR_NAME="Catppuccin-Mocha-Mauve"
                break
                ;;
            *) 
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Function to select icon pack
select_icons() {
    echo "Select icon pack:"
    select icon_pack in "Candy Icons" "We10X Black"; do
        case $icon_pack in
            "Candy Icons")
                ICON_FILE="candy-icons.tar.xz"
                ICON_NAME="Candy-icons"
                break
                ;;
            "We10X Black")
                ICON_FILE="We10X-black.tar.xz"
                ICON_NAME="We10X-Black"
                break
                ;;
            *) 
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Execute cursor and icon selection
select_cursors
select_icons

# Continue with installation
sudo apt update
sudo apt install -y mate-desktop-environment mate-terminal dconf-cli mate-themes unzip

sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.themes/Dracula
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.icons/{cursors,default}
sudo -u $REAL_USER mkdir -p ${WALLPAPER_DIR}

cd "${SCRIPT_DIR}"

# Handle cursors
if [[ "$CURSOR_FILE" == "M200.tar.gz" ]]; then
    tar xf "$CURSOR_FILE" -C ${REAL_HOME}/.icons/
    ln -s ${REAL_HOME}/.icons/M200/index.theme ${REAL_HOME}/.icons/default/index.theme
    sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme ${REAL_HOME}/.icons/M200/index.theme 20
elif [[ "$CURSOR_FILE" == "catppuccin-mocha-mauve-cursors.zip" ]]; then
    unzip "$CURSOR_FILE" -d ${REAL_HOME}/.icons/Catppuccin-Mocha-Mauve
    ln -s ${REAL_HOME}/.icons/Catppuccin-Mocha-Mauve/index.theme ${REAL_HOME}/.icons/default/index.theme
    sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme ${REAL_HOME}/.icons/Catppuccin-Mocha-Mauve/index.theme 20
fi

# Handle icon packs
if [[ "$ICON_FILE" == "candy-icons.tar.xz" ]]; then
    tar xf "$ICON_FILE" -C ${REAL_HOME}/.icons/
elif [[ "$ICON_FILE" == "We10X-black.tar.xz" ]]; then
    tar xf "$ICON_FILE" -C ${REAL_HOME}/.icons/
fi

# Change icon ownership
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.icons/

sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.config/autostart
cat > ${REAL_HOME}/.config/autostart/dracula-theme.desktop << EOL
[Desktop Entry]
Type=Application
Name=Dracula Theme
Exec=/tmp/mate-setup.sh
Hidden=false
X-MATE-Autostart-enabled=true
EOL
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/dracula-theme.desktop

cd "${SCRIPT_DIR}"
tar xf Dracula.tar.xz -C ${REAL_HOME}/.themes/
chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.themes/Dracula

cd "${SCRIPT_DIR}"
cp wallpaper_* "${WALLPAPER_DIR}/"
chown -R $REAL_USER:$REAL_USER ${WALLPAPER_DIR}


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
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_0.png</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_0.png</from>
    <to>${WALLPAPER_DIR}/wallpaper_1.png</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_1.png</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_1.png</from>
    <to>${WALLPAPER_DIR}/wallpaper_2.jpg</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_2.jpg</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_2.jpg</from>
    <to>${WALLPAPER_DIR}/wallpaper_3.png</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_3.png</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_3.png</from>
    <to>${WALLPAPER_DIR}/wallpaper_4.png</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_4.png</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_4.png</from>
    <to>${WALLPAPER_DIR}/wallpaper_5.png</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_5.png</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_5.png</from>
    <to>${WALLPAPER_DIR}/wallpaper_6.png</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_6.png</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_6.png</from>
    <to>${WALLPAPER_DIR}/wallpaper_7.webp</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_7.webp</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_7.webp</from>
    <to>${WALLPAPER_DIR}/wallpaper_8.webp</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_8.webp</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_8.webp</from>
    <to>${WALLPAPER_DIR}/wallpaper_9.webp</to>
  </transition>
  <static>
    <duration>1795.0</duration>
    <file>${WALLPAPER_DIR}/wallpaper_9.webp</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>${WALLPAPER_DIR}/wallpaper_9.webp</from>
    <to>${WALLPAPER_DIR}/wallpaper_0.png</to>
  </transition>
</background>
EOL
chown $REAL_USER:$REAL_USER "${WALLPAPER_DIR}/wallpaper-slideshow.xml"

cat > /tmp/mate-setup.sh << EOL
#!/bin/bash
sleep 5
# Configure Dracula theme
dconf write /org/mate/desktop/interface/gtk-theme "'Dracula'"
dconf write /org/mate/marco/general/theme "'Dracula'"
dconf write /org/mate/desktop/interface/icon-theme "'${ICON_NAME}'"
dconf write /org/mate/desktop/interface/cursor-theme "'${CURSOR_NAME}'"

# Terminal configuration
dconf write /org/mate/terminal/profiles/default/background-color "'#282a36'"
dconf write /org/mate/terminal/profiles/default/foreground-color "'#f8f8f2'"
dconf write /org/mate/terminal/profiles/default/palette "['#262626', '#E356A7', '#42E66C', '#E4F34A', '#9B6BDF', '#E64747', '#75D7EC', '#EFA554', '#7A7A7A', '#FF79C6', '#50FA7B', '#F1FA8C', '#BD93F9', '#FF5555', '#8BE9FD', '#FFB86C']"
dconf write /org/mate/terminal/profiles/default/use-theme-colors "false"
dconf write /org/mate/terminal/profiles/default/bold-color-same-as-fg "true"
dconf write /org/mate/terminal/profiles/default/cursor-color "'#f8f8f2'"

# Configure wallpaper with transitions
dconf write /org/mate/desktop/background/picture-filename "'${WALLPAPER_DIR}/wallpaper-slideshow.xml'"
dconf write /org/mate/desktop/background/picture-options "'zoom'"
dconf write /org/mate/desktop/background/show-desktop-icons "true"
EOL
chmod +x /tmp/mate-setup.sh
sudo -u $REAL_USER /tmp/mate-setup.sh

read -p "Do you want to close the session now to apply the changes? (y/n): " answer
case $answer in
    [Yy]* ) pkill -KILL -u $REAL_USER;;
    [Nn]* ) echo "Remember to close the session manually to see the changes.";;
    * ) echo "Please respond y/n";;
esac
