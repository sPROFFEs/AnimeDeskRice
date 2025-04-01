#!/bin/bash

###############################################################################
#                            Helper Functions                                 #
###############################################################################

# Function to prompt yes/no questions
ask_yes_no() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Function to select terminal type
select_terminal() {
    echo "Please select your current terminal:"
    select terminal in "GNOME Terminal" "XFCE Terminal" "MATE Terminal" "Skip terminal configuration"; do
        case $terminal in
            "GNOME Terminal" ) TERMINAL_TYPE="gnome"; break;;
            "XFCE Terminal" ) TERMINAL_TYPE="xfce"; break;;
            "MATE Terminal" ) TERMINAL_TYPE="mate"; break;;
            "Skip terminal configuration" ) TERMINAL_TYPE="skip"; break;;
            * ) echo "Invalid selection. Please try again.";;
        esac
    done
}

# Function to configure terminal font
configure_terminal_font() {
    case $TERMINAL_TYPE in
        "gnome")
            gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ font 'JetBrainsMono Nerd Font 10'
            gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ use-system-font false
            ;;
        "xfce")
            if [ -f ~/.config/xfce4/terminal/terminalrc ]; then
                sed -i 's/FontName=.*/FontName=JetBrainsMono Nerd Font 10/' ~/.config/xfce4/terminal/terminalrc
            else
                mkdir -p ~/.config/xfce4/terminal
                echo "[Configuration]" > ~/.config/xfce4/terminal/terminalrc
                echo "FontName=JetBrainsMono Nerd Font 10" >> ~/.config/xfce4/terminal/terminalrc
            fi
            ;;
        "mate")
            gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ use-system-font false
            gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ font 'JetBrainsMono Nerd Font 10'
            ;;
        "skip")
            echo "Skipping terminal font configuration..."
            ;;
    esac
}

###############################################################################
#                          Main Installation Steps                            #
###############################################################################

# Detect package manager
if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt-get"
else
    echo "This script requires apt package manager"
    exit 1
fi

# Update and install base packages
sudo $PKG_MGR update
sudo $PKG_MGR install -y zsh curl git unzip xclip fzf

# Ask about Kitty installation
if ask_yes_no "Would you like to install Kitty terminal?"; then
    sudo $PKG_MGR install -y kitty
    
    # Create Kitty configuration directory
    mkdir -p ~/.config/kitty
    
    # Create Kitty configuration with Nerd Font support
    cat > ~/.config/kitty/kitty.conf << 'EOL'
# Kitty Configuration for Nerd Fonts and Aesthetics

# Font configuration
font_family JetBrainsMono Nerd Font
font_size 10.0
adjust_line_height 110%

# Color scheme (Ubuntu-inspired)
background #300a24
foreground #ffffff
selection_background #444444
color0 #000000
color8 #555555
color1 #cc0000
color9 #ef2929
color2 #4e9a06
color10 #8ae234
color3 #c4a000
color11 #fce94f
color4 #3465a4
color12 #729fcf
color5 #75507b
color13 #ad7fa8
color6 #06989a
color14 #34e2e2
color7 #d3d7cf
color15 #eeeeec

# Cursor
cursor_shape block
cursor_blink_interval 0.5

# Window
window_padding_width 10
remember_window_size no
initial_window_width 100c
initial_window_height 30c

# Tabs
tab_bar_style powerline
tab_powerline_style angled

# Misc
enable_audio_bell no
visual_bell_duration 0.1
EOL

    # Make Kitty default terminal if user wants
    if ask_yes_no "Would you like to make Kitty your default terminal?"; then
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
    fi
else
    # If not installing Kitty, prompt for current terminal type
    select_terminal
fi

# Additional font and icon support packages
sudo $PKG_MGR install -y fonts-font-awesome

# Configure bat (handle different package names)
if ! dpkg -l | grep -q "^ii.*batcat"; then
    sudo $PKG_MGR install -y bat || sudo $PKG_MGR install -y batcat
fi
mkdir -p ~/.local/bin
if command -v batcat >/dev/null 2>&1; then
    ln -sf /usr/bin/batcat ~/.local/bin/bat
fi

# Install lsd with architecture detection
ARCH=$(dpkg --print-architecture)
TEMP_DEB="$(mktemp)"
wget -O "$TEMP_DEB" "https://github.com/Peltoche/lsd/releases/download/0.23.1/lsd_0.23.1_${ARCH}.deb"
sudo dpkg -i "$TEMP_DEB"
rm -f "$TEMP_DEB"

# Nerd Fonts installation
NERD_FONTS_DIR="$HOME/.local/share/fonts/NerdFonts"
mkdir -p "$NERD_FONTS_DIR"

# Download JetBrains Mono Nerd Font
echo "Downloading JetBrains Mono Nerd Font..."
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip -O /tmp/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d "$NERD_FONTS_DIR"
rm /tmp/JetBrainsMono.zip

# Update font cache
fc-cache -fv

# Configure terminal font if not using Kitty
if [ "$TERMINAL_TYPE" != "" ]; then
    configure_terminal_font
fi

###############################################################################
#                          Tmux Configuration                                 #
###############################################################################
configure_tmux() {
    # 1) Instalar tmux
    sudo $PKG_MGR install -y tmux

    # 2) Preguntar si se quiere configuración por defecto o modificar shortcuts
    echo "Would you like to use default tmux shortcuts (prefix Ctrl+b) or customize them?"
    select tmux_option in "Default (Ctrl+b)" "Customize prefix"; do
        case $tmux_option in
            "Default (Ctrl+b)")
                TMUX_PREFIX="C-b"
                break
                ;;
            "Customize prefix")
                echo "Enter the prefix you want (e.g., C-a):"
                read -r custom_prefix
                TMUX_PREFIX="$custom_prefix"
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done

    # 3) Crear la configuración ~/.tmux.conf
    cat > ~/.tmux.conf <<EOT
# Tmux Configuration

# History limit
set -g history-limit 10000

# Don't rename windows automatically
set -g allow-rename off

# Enable mouse mode (scroll, select, etc.)
set -g mouse on

# Use vi-style keys in copy-mode (optional; remove if you prefer emacs-style)
setw -g mode-keys vi

# Set prefix
unbind C-b
set -g prefix $TMUX_PREFIX
bind $TMUX_PREFIX send-prefix

# A simple line to show that we did install a custom prefix
# Additional custom config can go here...
# For instance, to copy to system clipboard, you could do:
# bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -sel clip -i"
EOT

    echo "Tmux installation and configuration complete."
}

if ask_yes_no "Would you like to install and configure tmux?"; then
    configure_tmux
fi

###############################################################################
#                          ZSH + Oh My Zsh Setup                               #
###############################################################################

# Install oh-my-zsh unattended
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install_omz.sh
# Prevent the script from doing 'exec zsh -l'
sed -i 's/exec zsh -l/echo "ZSH installed"/' install_omz.sh
sh install_omz.sh --unattended
rm install_omz.sh

# Install plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

if [ ! -f ~/.p10k.zsh ]; then
    touch ~/.p10k.zsh
    chmod 644 ~/.p10k.zsh
fi

# Enhanced .zshrc configuration
cat > ~/.zshrc << 'EOL'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Unicode and Icon Support
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color

export ZSH="$HOME/.oh-my-zsh"
export FZF_BASE="$HOME/.fzf"

# Powerlevel10k Configuration
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_MODE=nerdfont-complete
DISABLE_MAGIC_FUNCTIONS="true"

# Plugins with improved icon support
plugins=(
  sudo 
  fzf 
  zsh-syntax-highlighting 
  zsh-autosuggestions 
  git
)

source $ZSH/oh-my-zsh.sh

# Key bindings
bindkey -e
bindkey '^U' backward-kill-line
bindkey '^[[3~' delete-char
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Enable completion
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000

# Aliases with improved icons
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='batcat'
alias catn='/usr/bin/cat'
alias catnl='batcat --paging=never'

# Functions
function mkt(){
    mkdir {nmap,content,exploits,scripts}
}

function extractPorts(){
    ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
    echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
    echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
    echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
    echo $ports | tr -d '\n' | xclip -sel clip
    echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
    cat extractPorts.tmp; rm extractPorts.tmp
}

function fzf-lovely(){
    if [ "$1" = "h" ]; then
        fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
        echo {} is a binary file ||
        (batcat --style=numbers --color=always {} ||
        highlight -O ansi -l {} ||
        coderay {} ||
        rougify {} ||
        cat {}) 2> /dev/null | head -500'
    else
        fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
        echo {} is a binary file ||
        (batcat --style=numbers --color=always {} ||
        highlight -O ansi -l {} ||
        coderay {} ||
        rougify {} ||
        cat {}) 2> /dev/null | head -500'
    fi
}

function rmk(){
    scrub -p dod $1
    shred -zun 10 -v $1
}

# Load p10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL

# Create a default powerlevel10k config (~/.p10k.zsh) if it doesn't exist
cat > ~/.p10k.zsh << 'EOL'
# Generated by Powerlevel10k configuration wizard on 2024-01-27.
# Based on romkatv/powerlevel10k/config/p10k-rainbow.zsh.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh version check
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Nerd Font Configuration
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true

  # Prompt Segments
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # OS identifier
    dir                     # Current directory
    vcs                     # Git status
    status                  # Exit code of the last command
    command_execution_time  # Duration of last command
    context                 # User@hostname
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    background_jobs         # Presence of background jobs
  )

  # Prompt Styling
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%242F╭─'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%242F├─'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%242F╰─'

  # Separators
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B4'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B6'

  # OS Icon
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=254

  # Directory Configuration
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=93
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80

  # VCS (Git) Configuration
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=8

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  # Status Configuration
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=255
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=99

  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=232
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=196

  # Command Execution Time
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=255
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=105
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # Background Jobs
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=6
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=0

  # Context (User@Hostname)
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=208
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=0

  # Advanced Git Formatting Function
  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    local       meta='%7F' # white foreground
    local      clean='%0F' # black foreground
    local   modified='%0F' # black foreground
    local  untracked='%0F' # black foreground
    local conflicted='%1F' # red foreground

    local res

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"
      res+="${meta}#${clean}${tag//\%/%%}"
    fi

    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi

    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    fi

    if [[ -n $VCS_STATUS_ACTION ]]; then
      res+=" ${conflicted}${VCS_STATUS_ACTION}"
    fi
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
}

# Config file location
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

# Apply config options
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOL

# Ensure p10k source is in .zshrc
if ! grep -q "source ~/.p10k.zsh" ~/.zshrc; then
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
fi

# Change default shell to ZSH
if command -v zsh >/dev/null 2>&1; then
    sudo chsh -s "$(which zsh)" "$USER"
fi

# Optional: Run p10k configuration wizard (comment out if undesired)
p10k configure

# Start a new zsh login shell to load everything
zsh -l

echo "Installation complete. Please log out and log back in for changes to take effect."
