# Arch Update Checker
A KDE Plamsa Applet (Plasmoid) to check for Arch, AUR and Flatpak Updates, along with official Arch Linux Update News feed.

## Supported Wrappers
- [Paru](https://github.com/Morganamilo/paru)
- [Yay](https://github.com/Jguer/yay)
- [Trizen](https://github.com/trizen/trizen)
- [Pikaur](https://github.com/actionless/pikaur)
- [Aura](https://github.com/fosskers/aura)
- [Pacaur](https://github.com/rmarquis/pacaur) [Unmaintained]

## Screenshots

<div align="center">
<p>
  
![image](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/d475d25e-9636-40ce-871c-6e7f1b1f376c)<br/>
<i>Available updates list view</i>
<br/><br/>
</p>

<p>
  
![image](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/0dac6eaa-0ad9-482d-b58e-b1569cf6f071)<br/>
<i>Expanded details in list view</i>
<br/><br/>
</p>

<p>

![image](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/ba1a59a7-f8bd-417e-853b-d3754b4bad1e)<br/>
<i>Official Arch Linux News</i>

<br/><br/>
</p>

</div>

## Todo
- [ ] Add more pages to install/uninstall/manage packages
- [ ] Integration with pacman-offline
- [ ] Snap support(Unplanned)

## Installation


#### Required :
```pacman-contrib``` and ```pacutils``` are required.
The applet will automatically ask you to install them if not installed.

```sudo pacman -S pacman-contrib pacutils``` to install manually.

#### Recommended method :
Use the 'Download New Plasma Widgets' functionality in the edit mode and look for "Arch Update Checker".

#### Alternatively :
You can run:
```
git clone https://github.com/dhruv8sh/arch-update-checker
rm -rf ~/.local/share/plasma/plasmoids/org.kde.archupdatechecker/
cp -r arch-update-checker/ ~/.local/share/plasma/plasmoids/org.kde.archupdatechecker
systemctl --user restart plasma-plasmashell
```
This will restart your plasmashell
