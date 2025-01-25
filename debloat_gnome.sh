#!/bin/bash

# Colors for better visualization
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

# Function to ask yes/no questions
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Function to install packages
install_package() {
    echo -e "${BLUE}📦 Installing $1...${NC}"
    case "$1" in
        "librewolf")
            sudo apt update && sudo apt install extrepo -y
            sudo extrepo enable librewolf
            sudo apt update && sudo apt install librewolf -y
            ;;
        "brave")
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
            sudo apt update
            sudo apt install brave-browser -y
            ;;
        "vscodium")
            wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
            echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
            sudo apt update
            sudo apt install codium -y
            ;;
        "github-desktop")
            wget -qO - https://packagecloud.io/shiftkey/desktop/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
            sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'
            sudo apt update
            sudo apt install github-desktop -y
            ;;
        "flameshot")
            sudo apt install flameshot -y
            ;;
    esac
}

# Package categories
declare -A LIBREOFFICE_PACKAGES=(
    ["libreoffice-writer"]="Word processor similar to Microsoft Word"
    ["libreoffice-calc"]="Spreadsheet similar to Microsoft Excel"
    ["libreoffice-impress"]="Presentation software similar to Microsoft PowerPoint"
    ["libreoffice-draw"]="Diagram and drawing editor"
    ["libreoffice-math"]="Mathematical formula editor"
)

declare -A GNOME_APPS=(
    ["gnome-characters"]="Special characters and emoji selector"
    ["cheese"]="Webcam application"
    ["gnome-maps"]="Maps and navigation application"
    ["gnome-clocks"]="World clock, alarms, and timers"
    ["gnome-contacts"]="Contact manager"
    ["gnome-weather"]="Weather information"
    ["evolution"]="Email client"
)

declare -A GAMES=(
    ["aisleriot"]="" ["gnome-chess"]="" ["gnome-nibbles"]="" ["gnome-2048"]=""
    ["gnome-klotski"]="" ["gnome-mahjongg"]="" ["gnome-mines"]="" ["gnome-sudoku"]=""
    ["gnome-taquin"]="" ["gnome-tetravex"]="" ["gnome-robots"]="" ["quadrapassel"]=""
    ["five-or-more"]="" ["four-in-a-row"]="" ["hitori"]="" ["iagno"]=""
    ["lightsoff"]="" ["tali"]="" ["swell-foop"]=""
)

declare -A OPTIONAL_INSTALLS=(
    ["librewolf"]="Focused on privacy, fork of Firefox"
    ["brave"]="Privacy-focused web browser based on Chromium"
    ["flameshot"]="Advanced screenshot tool"
    ["vscodium"]="Free/Libre Open Source Software Binaries of VS Code"
    ["github-desktop"]="GitHub Desktop client"
)

# Counter for removed packages
removed_count=0

echo -e "${GREEN}🔍 Welcome to the interactive package manager${NC}"

# LibreOffice
echo -e "\n${YELLOW}== LibreOffice ==${NC}"
echo "These are the main LibreOffice applications. Which ones would you like to keep?"
for pkg in "${!LIBREOFFICE_PACKAGES[@]}"; do
    if is_package_installed "$pkg"; then
        if ! ask_yes_no "Keep $pkg? (${LIBREOFFICE_PACKAGES[$pkg]})"; then
            echo "📦 Removing $pkg..."
            sudo apt-get remove --purge "$pkg" -y 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "✅ $pkg successfully removed"
                ((removed_count++))
            fi
        fi
    fi
done

# GNOME Apps
echo -e "\n${YELLOW}== GNOME Applications ==${NC}"
for pkg in "${!GNOME_APPS[@]}"; do
    if is_package_installed "$pkg"; then
        if ! ask_yes_no "Keep $pkg? (${GNOME_APPS[$pkg]})"; then
            echo "📦 Removing $pkg..."
            sudo apt-get remove --purge "$pkg" -y 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "✅ $pkg successfully removed"
                ((removed_count++))
            fi
        fi
    fi
done

# Games
echo -e "\n${YELLOW}== Games ==${NC}"
if ask_yes_no "Would you like to remove all pre-installed games?"; then
    for pkg in "${!GAMES[@]}"; do
        if is_package_installed "$pkg"; then
            echo "📦 Removing $pkg..."
            sudo apt-get remove --purge "$pkg" -y 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "✅ $pkg successfully removed"
                ((removed_count++))
            fi
        fi
    done
fi

# Cleanup
echo -e "\n${BLUE}🧹 Cleaning up the system...${NC}"
sudo apt-get autoremove -y
sudo apt-get clean
sudo apt-get autoclean

# Optional installations
echo -e "\n${YELLOW}== Optional Installations ==${NC}"
for pkg in "${!OPTIONAL_INSTALLS[@]}"; do
    if ask_yes_no "Would you like to install $pkg? (${OPTIONAL_INSTALLS[$pkg]})"; then
        install_package "$pkg"
    fi
done

# Show summary
echo -e "\n${GREEN}📊 Summary:${NC}"
echo "Packages removed: $removed_count"

# Show freed space
df_before=$(df / | tail -n 1 | awk '{print $4}')
sleep 2
df_after=$(df / | tail -n 1 | awk '{print $4}')
space_freed=$((df_after - df_before))

if [ $space_freed -gt 0 ]; then
    echo "💾 Space freed: $(($space_freed / 1024)) MB"
fi

# GDM3 Configuration
echo -e "\n${YELLOW}== GDM3 Configuration ==${NC}"
if ask_yes_no "Would you like to enable and configure GDM3 as login manager?"; then
    echo -e "${BLUE}📦 Installing and configuring GDM3...${NC}"
    
    # Install GDM3 and required dependencies
    if ! sudo apt install gdm3 libglib2.0-dev dconf-cli git -y; then
        echo -e "${RED}❌ Failed to install GDM3 and dependencies${NC}"
        return 1
    fi
    
    if ! sudo systemctl enable gdm3; then
        echo -e "${RED}❌ Failed to enable GDM3${NC}"
        return 1
    fi
    
    if ask_yes_no "Would you like to customize the GDM3 wallpaper?"; then
        # Create temporary directory for gdm-tools
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR" || {
            echo -e "${RED}❌ Failed to create temporary directory${NC}"
            return 1
        }
        
        # Clone and install gdm-tools
        if ! git clone --depth=1 https://github.com/realmazharhussain/gdm-tools.git; then
            echo -e "${RED}❌ Failed to clone gdm-tools repository${NC}"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            return 1
        fi
        
        cd gdm-tools || {
            echo -e "${RED}❌ Failed to enter gdm-tools directory${NC}"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            return 1
        }
        
        if ! ./install.sh; then
            echo -e "${RED}❌ Failed to install gdm-tools${NC}"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            return 1
        fi
        
        # Ask for wallpaper path
        while true; do
            read -p "Please enter the full path to the wallpaper (must be a .jpg or .png file): " wallpaper_path
            if [ -f "$wallpaper_path" ]; then
                # Verify file is an image
                extension="${wallpaper_path##*.}"
                if [[ ! "$extension" =~ ^(jpg|jpeg|png)$ ]]; then
                    echo -e "${RED}❌ File must be a .jpg, .jpeg or .png image${NC}"
                    continue
                fi
                
                # Set GDM theme using gdm-tools
                if ! set-gdm-theme set -b "$wallpaper_path"; then
                    echo -e "${RED}❌ Failed to set GDM theme${NC}"
                    continue
                fi
                
                echo -e "${GREEN}✅ Wallpaper successfully configured using gdm-tools${NC}"
                break
            else
                echo -e "${RED}❌ Specified path doesn't exist or is invalid${NC}"
            fi
        done
        
        # Cleanup
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
    fi
fi
    
    echo -e "${GREEN}✅ GDM3 has been enabled and configured${NC}"
    
    if ask_yes_no "Would you like to apply changes and restart the system now?"; then
        echo -e "${YELLOW}⚠️  System will restart in 5 seconds...${NC}"
        echo -e "${YELLOW}⚠️  Make sure you've saved all your work${NC}"
        sleep 1
        echo "5..."
        sleep 1
        echo "4..."
        sleep 1
        echo "3..."
        sleep 1
        echo "2..."
        sleep 1
        echo "1..."
        # Disable other display managers if they exist
        if systemctl is-active --quiet lightdm; then
            sudo systemctl disable lightdm
        fi
        if systemctl is-active --quiet sddm; then
            sudo systemctl disable sddm
        fi
        systemctl start gdm3
        # Reboot system
        sudo systemctl reboot
    else
        echo -e "${BLUE}ℹ️  You can start GDM3 later by rebooting your system${NC}"
    fi
fi

echo -e "\n${GREEN}✨ Process completed!${NC}"