#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar el banner
show_banner() {
    clear
    echo -e "${YELLOW}"
    echo "+------------------------------------------------+"
    echo "|              Pacman Package Manager             |"
    echo "|                                                 |"
    echo -e "|   ${RED}●${YELLOW}   ${BLUE}⬤${RED}   ${YELLOW}⬤${RED}   ${GREEN}⬤${RED}   ${MAGENTA}⬤${YELLOW}   ·   ·   ·   ·             |"
    echo "|                                                 |"
    echo "|              Arch/Manjaro Tools                 |"
    echo "+------------------------------------------------+"
    echo -e "${NC}\n"
}

# Función para mostrar el menú
show_menu() {
    echo -e "${YELLOW}Seleccione una opción:${NC}"
    echo ""
    echo "1) Actualizar lista de paquetes (pacman -Sy)"
    echo "2) Actualizar sistema completo (pacman -Syu)"
    echo "3) Instalar un paquete"
    echo "4) Desinstalar un paquete"
    echo "5) Eliminar paquete y sus configuraciones"
    echo "6) Eliminar dependencias no usadas"
    echo "7) Buscar un paquete"
    echo "8) Limpiar caché de paquetes"
    echo "9) Actualizar sistema con AUR (yay -Syu)"
    echo "10) Listar paquetes instalados"
    echo "11) Información de un paquete"
    echo "12) Ayuda rápida de Pacman"
    echo "0) Salir"
    echo ""
}

# Función para pausar
pause() {
    echo ""
    read -p "Presione ENTER para continuar..."
}

# Función para mostrar ayuda rápida
show_help() {
    echo -e "${GREEN}Guía Rápida de Pacman${NC}"
    echo "-------------------"
    echo -e "${YELLOW}Flags comunes:${NC}"
    echo "-S: Sincronizar/instalar"
    echo "-R: Remover"
    echo "-Q: Consultar"
    echo "-y: Actualizar base de datos"
    echo "-u: Actualizar sistema"
    echo "-n: Eliminar archivos de configuración"
    echo "-s: Buscar"
    echo "-d: Solo dependencias"
    echo "-t: No necesarios"
    echo "-q: Salida silenciosa"
    echo ""
    echo -e "${YELLOW}Ejemplos comunes:${NC}"
    echo "pacman -Ss paquete    # Buscar paquete"
    echo "pacman -Si paquete    # Info de paquete"
    echo "pacman -Qe           # Listar paquetes explícitamente instalados"
    echo "pacman -Qs paquete    # Buscar en paquetes instalados"
}

# Función principal
main() {
    while true; do
        show_banner
        show_menu
        read -p "Opción: " choice

        case $choice in
            1)
                echo -e "${GREEN}Actualizando lista de paquetes...${NC}"
                sudo pacman -Sy
                ;;
            2)
                echo -e "${GREEN}Actualizando sistema completo...${NC}"
                sudo pacman -Syu
                ;;
            3)
                read -p "Nombre del paquete a instalar: " package
                echo -e "${GREEN}Instalando $package...${NC}"
                sudo pacman -S "$package"
                ;;
            4)
                read -p "Nombre del paquete a desinstalar: " package
                echo -e "${RED}Desinstalando $package...${NC}"
                sudo pacman -R "$package"
                ;;
            5)
                read -p "Nombre del paquete a eliminar completamente: " package
                echo -e "${RED}Eliminando $package y sus configuraciones...${NC}"
                sudo pacman -Rns "$package"
                ;;
            6)
                echo -e "${YELLOW}Eliminando dependencias no usadas...${NC}"
                sudo pacman -Rns $(pacman -Qdtq)
                ;;
            7)
                read -p "Nombre del paquete a buscar: " package
                echo -e "${BLUE}Buscando $package...${NC}"
                pacman -Ss "$package"
                ;;
            8)
                echo -e "${YELLOW}Limpiando caché de paquetes...${NC}"
                sudo pacman -Sc
                ;;
            9)
                if command -v yay &> /dev/null; then
                    echo -e "${GREEN}Actualizando sistema con AUR...${NC}"
                    yay -Syu
                else
                    echo -e "${RED}yay no está instalado. ¿Desea instalarlo? (s/n)${NC}"
                    read install_yay
                    if [[ $install_yay == "s" ]]; then
                        sudo pacman -S --needed git base-devel
                        git clone https://aur.archlinux.org/yay.git
                        cd yay
                        makepkg -si
                        cd ..
                        rm -rf yay
                    fi
                fi
                ;;
            10)
                echo -e "${BLUE}Listando paquetes instalados explícitamente...${NC}"
                pacman -Qe
                ;;
            11)
                read -p "Nombre del paquete: " package
                echo -e "${BLUE}Información de $package:${NC}"
                pacman -Si "$package"
                ;;
            12)
                show_help
                ;;
            0)
                echo -e "${GREEN}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                ;;
        esac
        pause
    done
}

# Función para detectar y configurar alias
setup_alias() {
    local shell_rc=""
    local current_shell=$(basename "$SHELL")
    
    # Detectar archivo rc según el shell
    if [ "$current_shell" = "zsh" ]; then
        shell_rc="${HOME}/.zshrc"
    elif [ "$current_shell" = "bash" ]; then
        shell_rc="${HOME}/.bashrc"
    else
        echo -e "${RED}Shell no soportado. Solo se soporta zsh y bash.${NC}"
        return 1
    fi

    # Verificar si el script está en una ubicación permanente
    local script_path=$(readlink -f "$0")
    if [[ $script_path != "/usr/local/bin"* ]]; then
        echo -e "${YELLOW}¿Deseas instalar el script en /usr/local/bin? (s/n):${NC} "
        read install_choice
        if [[ $install_choice == "s" ]]; then
            sudo cp "$script_path" "/usr/local/bin/pacman-manager"
            sudo chmod +x "/usr/local/bin/pacman-manager"
            script_path="/usr/local/bin/pacman-manager"
            echo -e "${GREEN}Script instalado en /usr/local/bin/pacman-manager${NC}"
        fi
    fi

    # Verificar si ya existe algún alias para el script
    if grep -q "alias.*=.*pacman-manager" "$shell_rc" 2>/dev/null; then
        echo -e "${YELLOW}Ya existe un alias para este script en $shell_rc${NC}"
        echo -e "Alias actuales encontrados:"
        grep "alias.*=.*pacman-manager" "$shell_rc"
        return 0
    fi

    # Preguntar si desea crear un alias
    echo -e "${YELLOW}¿Deseas crear un alias para este script? (s/n):${NC} "
    read create_alias
    if [[ $create_alias == "s" ]]; then
        echo -e "${YELLOW}Introduce el nombre del alias (por ejemplo: pm):${NC} "
        read alias_name
        if [[ -n $alias_name ]]; then
            # Verificar si el alias ya está en uso
            if grep -q "alias $alias_name=" "$shell_rc" 2>/dev/null; then
                echo -e "${RED}El alias '$alias_name' ya está en uso.${NC}"
                return 1
            fi
            
            # Añadir el alias
            echo "alias $alias_name=\"$script_path\"" >> "$shell_rc"
            echo -e "${GREEN}Alias '$alias_name' creado exitosamente.${NC}"
            echo -e "${YELLOW}Por favor, ejecuta 'source $shell_rc' o reinicia tu terminal para usar el alias.${NC}"
        else
            echo -e "${RED}Nombre de alias inválido${NC}"
            return 1
        fi
    fi
}

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Nota: Algunas operaciones requerirán permisos de superusuario${NC}"
fi

# Verificar si es la primera ejecución y configurar alias
if [[ ! -f "/usr/local/bin/pacman-manager" ]] && [[ ! -f "$HOME/.pacman-manager-configured" ]]; then
    setup_alias
    touch "$HOME/.pacman-manager-configured"
fi

# Iniciar el script
main