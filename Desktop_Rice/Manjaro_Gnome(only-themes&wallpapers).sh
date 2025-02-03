#!/bin/bash
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd $REAL_USER | cut -d: -f6)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
WALLPAPER_DIR="${REAL_HOME}/Wallpapers"

# Instalación de dependencias básicas
echo "Instalando dependencias necesarias..."
sudo pacman -S --needed --noconfirm gnome-tweaks dconf unzip

# Crear directorios necesarios
echo "Creando directorios..."
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.themes
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.icons/{cursors,default}
sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.icons/Candy-icons
sudo -u $REAL_USER mkdir -p ${WALLPAPER_DIR}

# Instalar temas e íconos
echo "Instalando temas e íconos..."
cd "${SCRIPT_DIR}"

# Cursor M200
if [ -f M200.tar.gz ]; then
    echo "Instalando tema de cursor M200..."
    tar xf M200.tar.gz -C ${REAL_HOME}/.icons/
    ln -sf ${REAL_HOME}/.icons/M200/index.theme ${REAL_HOME}/.icons/default/index.theme
    sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme ${REAL_HOME}/.icons/M200/index.theme 20
    chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.icons/M200
else
    echo "Archivo M200.tar.gz no encontrado"
fi

# Candy Icons
if [ -f candy-icons.tar.xz ]; then
    echo "Instalando Candy Icons..."
    tar xf candy-icons.tar.xz -C ${REAL_HOME}/.icons/
    chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.icons/Candy-icons
else
    echo "Archivo candy-icons.tar.xz no encontrado"
fi

# Tema Tokyo Night
if [ -f Tokyonight-Dark-BL-GS.zip ]; then
    echo "Instalando tema Tokyo Night..."
    TMP_DIR=$(mktemp -d)
    unzip -o Tokyonight-Dark-BL-GS.zip -d "$TMP_DIR"
    sudo -u $REAL_USER mkdir -p ${REAL_HOME}/.themes/Tokyonight-Dark-BL-GS
    mv "$TMP_DIR/gnome-shell" ${REAL_HOME}/.themes/Tokyonight-Dark-BL-GS/
    rm -rf "$TMP_DIR"
    chown -R $REAL_USER:$REAL_USER ${REAL_HOME}/.themes/Tokyonight-Dark-BL-GS
else
    echo "Archivo Tokyonight-Dark-BL-GS.zip no encontrado"
fi

# Configurar Wallpapers
echo "Configurando wallpapers..."
if ls wallpaper_* 1> /dev/null 2>&1; then
    cp wallpaper_* "${WALLPAPER_DIR}/"
    chown -R $REAL_USER:$REAL_USER "${WALLPAPER_DIR}"

    # Crear archivo de configuración para slideshow
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
  ext_current=$(ls ${WALLPAPER_DIR}/wallpaper_$i.* 2>/dev/null | grep -o '\.[^.]*$')
  ext_next=$(ls ${WALLPAPER_DIR}/wallpaper_$next.* 2>/dev/null | grep -o '\.[^.]*$')
  if [ -n "$ext_current" ] && [ -n "$ext_next" ]; then
    echo "  <static>"
    echo "    <duration>1795.0</duration>"
    echo "    <file>${WALLPAPER_DIR}/wallpaper_$i$ext_current</file>"
    echo "  </static>"
    echo "  <transition>"
    echo "    <duration>5.0</duration>"
    echo "    <from>${WALLPAPER_DIR}/wallpaper_$i$ext_current</from>"
    echo "    <to>${WALLPAPER_DIR}/wallpaper_$next$ext_next</to>"
    echo "  </transition>"
  fi
done)
</background>
EOL
    chown $REAL_USER:$REAL_USER "${WALLPAPER_DIR}/wallpaper-slideshow.xml"
else
    echo "No se encontraron archivos de wallpaper (wallpaper_*)"
fi

# Script de autostart para aplicar temas
echo "Configurando script de autostart..."
mkdir -p ${REAL_HOME}/.config/autostart

cat > ${REAL_HOME}/.config/autostart/theme-setup.sh << 'EOL'
#!/bin/bash
sleep 5
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

cat > ${REAL_HOME}/.config/autostart/theme-setup.desktop << EOL
[Desktop Entry]
Type=Application
Name=Theme Setup
Exec=${REAL_HOME}/.config/autostart/theme-setup.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL
chown $REAL_USER:$REAL_USER ${REAL_HOME}/.config/autostart/theme-setup.desktop

echo "Configuración completada. Por favor:"
echo "1. Asegúrate de que la extensión 'User Themes' esté habilitada en GNOME Extensions"
echo "2. Cierra la sesión y reinicia para aplicar los cambios"
echo "3. Si el tema no se aplica automáticamente, puedes aplicarlo manualmente usando GNOME Tweaks"

read -p "¿Deseas cerrar la sesión ahora para aplicar los cambios? (s/n): " answer
case $answer in
    [Ss]* ) pkill -KILL -u $REAL_USER;;
    [Nn]* ) echo "Recuerda cerrar la sesión manualmente para ver los cambios.";;
    * ) echo "Por favor responde s/n";;
esac