<div align="center">

# 🌸 Anime Desk Rice

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Debian](https://img.shields.io/badge/Debian-D70A53?style=flat&logo=debian&logoColor=white)
![Kali](https://img.shields.io/badge/Kali-268BEE?style=flat&logo=kalilinux&logoColor=white)

*Transform your Debian/Kali system with an anime-inspired aesthetic. Featuring Tokyo Night theme, custom terminal configurations, and a sleek dock setup. Turn your desktop into a beautiful and functional workspace with just one script.* 🎋

[Features](#features) • [Installation](#installation) • [Screenshots](#screenshots) • [Themes](#included-themes) • [Customization](#customization)

![Preview Image Placeholder](preview.png)

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

#### Kali
```bash
cd Terminal_Rice
chmod +x ZSH_THEME_kali.sh
./ZSH_THEME_kali.sh
```
#### Debian / Ubuntu
```bash
cd Terminal_Rice
chmod +x ZSH_THEME_debian-ubuntu.sh
./ZSH_THEME_debian-ubuntu.sh
```
### Desktop

It should work for debian based distros, but I only tested it on Kali and debian.

1. Gnome environment
```bash
cd Desktop_Rice
chmod +x Gnome_setup.sh
./Gnome_setup.sh
```
2. Mate environment
```bash
cd Desktop_Rice
chmod +x Mate_setup.sh
./Mate_setup.sh
```
### Login manager

By default, the gnome environment will install gdm3 as the login manager but it`s not enabled by default.

If you want to enable it, you can do it by running the following command:
```bash
sudo systemctl enable gdm3
sudo systemctl start gdm3
```
Then you can log out and log back in to enable the login manager.

## 🎨 Included Themes

- **Tokyo Night**: Modern dark theme
- **Catppuccin Mocha**: Clean dock theme
- **Sweet Purple**: Sleek icon theme
- **M200 Cursor**: Minimalist cursor theme

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
