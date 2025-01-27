<div align="center">

# 🌸 Anime Desk Rice

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Debian](https://img.shields.io/badge/Debian-D70A53?style=flat&logo=debian&logoColor=white)
![Kali](https://img.shields.io/badge/Kali-268BEE?style=flat&logo=kalilinux&logoColor=white)

*Transform your Debian/Kali system with an anime-inspired aesthetic. Featuring Tokyo Night theme, custom terminal configurations, and a sleek dock setup. Turn your desktop into a beautiful and functional workspace with just one script.* 🎋

</div>

## ✨ Features

- 🎨 Complete theming for GNOME and MATE desktop environments
- 🖥️ Tokyo Night theme integration
- 🔧 Custom terminal configurations for both Debian and Kali
- 🚀 Plank dock with Catppuccin theme
- 🎭 Sweet Purple icon theme
- 🌅 Dynamic wallpaper slideshow
- ⚡ One-click installation

## 📦 Requirements

- Debian or Kali Linux
- GNOME or MATE desktop environment
- Git
- Internet connection for package installation

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/sproffes/AnimeDeskRice.git
cd AnimeDeskRice
```
Or go to releases if you only want to download Terminal or Desktop setups.

2. Choose your rice for terminal or desktop:

### Terminal
The script now includes an optional Kitty terminal installation. While Kitty is recommended for the best experience, it's not mandatory.

Terminal configuration support is being expanded. If your terminal is not currently in the supported list (GNOME, XFCE, MATE), you'll need to manually configure the JetBrainsMono Nerd font in your terminal settings.

#### Kali Linux Installation
```bash
cd Terminal_Rice
chmod +x ZSH_THEME_kali+kitty.sh
./ZSH_THEME_kali+kitty.sh
```

#### Debian / Ubuntu Installation
```bash
cd Terminal_Rice
chmod +x ZSH_THEME_debian-ubuntu+kitty.sh
./ZSH_THEME_debian-ubuntu+Kitty.sh
```

### Desktop Environments
The desktop configuration scripts are designed for Debian-based distributions. Testing has been primarily conducted on Kali Linux and Debian.

1. GNOME Environment
```bash
cd Desktop_Rice
chmod +x Gnome_setup.sh
./Gnome_setup.sh
```

2. MATE Environment
```bash
cd Desktop_Rice
chmod +x Mate_setup.sh
./Mate_setup.sh
```

Log out and log back in to apply the changes.

### GNOME Customization Tools

#### GNOME Debloater
A utility is included to help remove pre-installed applications like LibreOffice or GNOME games. It also offers the option to install alternative applications such as:
- VSCodium
- Brave Browser
- LibreWolf
- Additional useful packages

#### GNOME Uninstaller (Beta)
A tool to remove the GNOME desktop environment is included but is currently in beta. It attempts to remove all main GNOME packages. If the system reboots unexpectedly during uninstallation, manually complete the cleanup with:

```bash
sudo apt autoremove -y && sudo apt purge
```

⚠️ **Warning**: Ensure you have an alternative desktop environment installed before using the GNOME uninstaller. Use at your own risk.

## 🎨 Included Themes

### GTK Themes
- **Dracula**: Dark purple theme with vibrant colors
  - Sleek, modern dark theme
  - High contrast
  - Popular among developers

- **Tokyo Night**: Modern dark theme
  - Soft dark color palette
  - Minimalist design
  - Inspired by the night skyline of Tokyo

- **Catppuccin Mocha**: Clean dock theme
  - Sophisticated color scheme
  - Smooth, muted colors
  - Excellent readability

### Icon Packs
- **Candy Icons**: Sleek icon theme
  - Colorful and modern icons
  - Consistent design language
  - Supports multiple desktop environments

- **We10X**: Windows-inspired icon set
  - Flat design 
  - Clean and minimalist
  - Compatible with various Linux distributions

- **Catppuccin Icons**: Matching icon theme
  - Designed to complement Catppuccin theme
  - Soft, pastel color palette
  - Elegant and cohesive look

### Cursor Themes
- **M200 Cursor**: Weeabo cursor theme
  - Anime-inspired design
  - Smooth animations
  - Unique aesthetic

- **Catppuccin Cursors**
  - Matching cursor theme for Catppuccin palette
  - Subtle and elegant
  - Consistent with Catppuccin design philosophy

### Additional Customizations
- Powerlevel10k ZSH theme
- Nerd Fonts support
- Custom keyboard shortcuts
- Performance optimizations

## ⚙️ Customization

You can modify the scripts to suit your preferences:
- Edit wallpaper rotation time in the XML configuration
- Adjust Plank dock settings
- Modify terminal colors
- Change icon themes

## 📸 Screenshots

![Kali-Mate](/assets/kalimate.gif)

![Kali-Gnome](/assets/kalignome.gif)

![Debian-Gnome](/assets/debiangnome.gif)

![ZSH](/assets/zshinstall.gif)
## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Credits

This is just an automation tool. All themes and visual elements belong to their respective creators. See [CREDITS.md](CREDITS.md) for full credits and licenses.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 
Note that this only applies to the automation scripts. All themes and assets belong to their respective owners.

## 💭 Inspiration

Inspired by the amazing Linux ricing community and the beautiful world of anime aesthetics.

---

<div align="center">
Made with 💜 by [Your Name]
</div>
