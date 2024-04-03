# Arch Update Notifier
A KDE Plamsa Applet (Plasmoid) to check for Arch, AUR and Flatpak Updates.

## Screenshots

![Screenshot_20240317_035250](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/7a0fb498-0611-418c-8758-ac16f01ae678)

![Screenshot_20240317_035940](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/f4540d46-a7a6-4ae5-8fa1-d672713691c7)

## Todo
- [x] Support for YAY, Trizen, Paru and Pikaur
- [x] Flatpak Support
- [x] Rewrite to look native
  - [x] Details on item expand
  - [x] Flatpak details on expand
  - [x] Ask for modifying singular updates
  - [x] Complete support for AURA and PACAUR
  - [ ] (8/10) Better error handling
  - [ ] (1/2) Extensive logging support
- [x] Notification on update
  - [x] Basic Support
  - [ ] Support for update diff
- [ ] (1/3) Support for Arch Linux Update News
- [ ] (1/2) Support for mirrorlist update
- [x] Support for multiple consoles ( currently planned for alacritty )
- [ ] Snap support


## Installation
```
git clone https://github.com/dhruv8sh/arch-update-checker/
cd arch-update-checker
kpackagetool6 -i .
```
Or just use the plasma "Download new widget" functionality

