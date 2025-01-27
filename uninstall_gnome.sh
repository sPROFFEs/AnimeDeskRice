#!/bin/bash

print_error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

print_success() {
    echo -e "\e[32m[OK]\e[0m $1"
}

if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run with sudo or as root" 
   exit 1
fi

# Function to uninstall packages
uninstall_packages() {
    local packages=(
        "gnome-*"
        "gdm3"
        "nautilus"
        "gnome-shell"
        "gnome-session"
        "gnome-control-center"
        "gnome-terminal"
        "gnome-desktop3-data"
        "gnome-common"
        "gnome-icon-theme"
    )

    for pkg in "${packages[@]}"; do
        apt remove --purge -y $pkg
        if [ $? -eq 0 ]; then
            print_success "Uninstalled: $pkg"
        else
            print_error "Error uninstalling: $pkg"
        fi
    done
}

# Clean user configurations
clean_user_configs() {
    local home_dirs=$(grep "/home/" /etc/passwd | cut -d: -f6)
    
    for home in $home_dirs; do
        echo "Cleaning GNOME configurations in $home"
        rm -rf "$home"/.config/gnome*
        rm -rf "$home"/.gnome*
        rm -rf "$home"/.local/share/gnome*
    done
}

# Clean system configurations
clean_system_configs() {
    rm -rf /etc/gdm3
    rm -rf /var/lib/gdm3
    print_success "System configurations removed"
}

# Clean orphaned packages
clean_orphaned_packages() {
    apt autoremove -y
    apt autoclean
    print_success "Orphaned packages removed"
}

# Configure alternative display manager
set_alternative_display_manager() {
    if dpkg -l | grep -q lightdm; then
        dpkg-reconfigure lightdm
        print_success "LightDM configured as display manager"
    else
        print_error "LightDM not found. Consider installing an alternative window manager."
    fi
}

# Reboot recommendation
reboot_recommendation() {
    read -p "Do you want to reboot the system now? (y/n): " reboot_choice
    case $reboot_choice in
        [Yy]* ) 
            echo "Rebooting the system..."
            systemctl reboot
            ;;
        [Nn]* ) 
            echo "IMPORTANT: Please reboot the system manually to complete the GNOME removal."
            echo "Recommended reboot commands:"
            echo "- 'sudo reboot'"
            echo "- 'sudo shutdown -r now'"
            ;;
        * ) 
            echo "Please respond with y or n"
            reboot_recommendation
            ;;
    esac
}

# Main function
main() {
    echo "Starting GNOME uninstallation..."
    
    # Update package list
    apt update
    
    # Uninstall packages
    uninstall_packages
    
    # Clean user configurations
    clean_user_configs
    
    # Clean system configurations
    clean_system_configs
    
    # Clean orphaned packages
    clean_orphaned_packages
    
    # Configure alternative display manager
    set_alternative_display_manager
    
    echo "GNOME uninstallation completed."
    
    # Recommend reboot
    reboot_recommendation
}

# Execute main function
main

exit 0