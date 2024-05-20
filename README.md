# Arch Update Checker
A KDE Plamsa Applet (Plasmoid) to check for Arch, AUR and Flatpak Updates.

## Screenshots

<div align="center">
<p>
  
![Screenshot_20240508_142812](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/aebae6ed-d075-4a8c-b5ee-57de7fe6c1c7)<br/>
<i>Available updates view</i>
<br/><br/>
</p>

<p>
  
![Screenshot_20240508_143330](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/5edb0542-12f2-40e2-8cb8-1faa348b96ff)<br/>
<i>Arch Linux Update News</i>
<br/><br/>
</p>

<p>

![Screenshot_20240508_143537](https://github.com/dhruv8sh/arch-update-checker/assets/67322047/91ee7d25-54fd-4191-b65e-51533aa27f8e)<br/>
<i>Setup screen (Now hidden until out of Beta)</i>

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
- [x] Support for pamac
- [ ] Automatic setup
- [ ] Snap support


## Installation


#### Required :
You need to install ```pacutils``` and ```pacman-contrib``` packages for the applet to work correctly.
Run ```sudo pacman -S pacutils pacman-contrib```.

#### Recommended method :
Use the `Download new widget` functionality to obtain the widget (currently there are no auto updates for widgets on plasma 6, and you can't update them via the update button, [relevant](https://bugs.kde.org/show_bug.cgi?id=483570) [issues](https://discuss.kde.org/t/kde-6-widgets-fail-to-update/14337))

If the applet doesn't get automatically added to your system tray, run:
`systemctl --user restart plasma-plasmashell` - this will restart your plasma shell
or log out and back in.

#### Alternatively,
you can use `kpackagetool6` (currently broken) or `plasmapkg2` (not part of a clean plasma 6 install)
```
git clone https://github.com/dhruv8sh/arch-update-checker/
cd arch-update-checker
kpackagetool6 -i .
```
