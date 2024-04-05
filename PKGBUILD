# Maintainer: Dhruvesh Surolia <dhruv8sh@proton.me>

_gitname=arch-update-checker
pkgname=plasma6-applets-archupdatechecker
pkgver=r82.ec11d06
pkgrel=1
pkgdesc="A KDE Plasma 6 applet to show and install all your updates."
arch=('any')
url="https://github.com/dhruv8sh/$_gitname"
license=('GPL-2.0')
depends=('plasma-workspace')
makedepends=('git')
source=("git+$url.git")
sha256sums=('SKIP')

package() {
  _pkgdir="$pkgdir/usr/share/plasma/plasmoids/org.kde.archupdatechecker"
  mkdir -p "$_pkgdir"
  cp -r $_gitname/* $_pkgdir
  rm $_pkgdir/README.md
}
