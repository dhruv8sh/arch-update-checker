# Arch Update Checker
A KDE Plamsa Applet (Plasmoid) to check for Arch, AUR and Flatpak Updates.

## Screenshots

<div align="center">
<p>

![Screenshot_20240405_002625](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/395a88d8-2d40-46fb-84d3-01be429edb5f)<br/>
<i>Available updates view</i>
<br/><br/>
</p>

<p>

![Screenshot_20240405_002649](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/c5d726d4-a769-4dba-918b-06e921650e5e)<br/>
<i>Arch Linux Update News</i>
<br/><br/>
</p>

<p>

![image](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/7ff8ae04-e257-4214-b0ed-d468f1410b54)<br/>
<i>Setup screen</i>

<br/><br/>
</p>

</div>

## Todo
- [x] Support for YAY, Trizen, Paru and Pikaur
- [x] Flatpak Support
- [x] Complete support for AURA and PACAUR
- [x] Orphan Removal
- [x] Rewrite to look native
  - [x] Details on item expand
  - [x] Flatpak details on expand
  - [x] Ask for modifying singular updates
  - [x] Better error handling
  - [x] Extensive logging support
- [x] Notification on update
  - [x] Basic Support
  - [x] Native Support
  - [ ] Support for update diff
- [x] Support for Arch Linux Update News
- [ ] (1/2) Support for mirrorlist update
- [x] Support for alacritty and kitty
- [ ] Snap support


## Installation
```
git clone https://github.com/dhruv8sh/arch-update-checker/
cd arch-update-checker
kpackagetool6 -i .
```
If ```kpackagetool6``` does not work use ```plasmapkg2``` instead.
Or just use the plasma "Download new widget" functionality

