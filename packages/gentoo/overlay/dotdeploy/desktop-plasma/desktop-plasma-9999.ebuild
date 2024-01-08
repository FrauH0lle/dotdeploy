EAPI=8

DESCRIPTION="desktop/plasma module meta package."
HOMEPAGE="https://gitlab.com/DonHugo/dotfiles"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

# Meta packages
RDEPEND="
	kde-plasma/plasma-meta
	kde-apps/kdecore-meta
	kde-apps/kdeadmin-meta
	kde-apps/kdeutils-meta
"

# KDE tools
RDEPEND="
	${RDEPEND}
	kde-misc/kdeconnect
	kde-misc/skanlite
	kde-apps/kdenetwork-filesharing
	kde-apps/gwenview
	kde-apps/okular
	kde-apps/spectacle
"

# Evolution PIM
RDEPEND="
	${RDEPEND}
	mail-client/evolution
	gnome-extra/evolution-ews
"

# Themes
RDEPEND="
	${RDEPEND}
	x11-themes/papirus-icon-theme
"

# Flatpak
RDEPEND="
	${RDEPEND}
	sys-apps/xdg-desktop-portal-gtk
"
