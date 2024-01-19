EAPI=8

DESCRIPTION="Host 'yamato' meta package."
HOMEPAGE="https://gitlab.com/DonHugo/dotfiles"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	sys-kernel/gentoo-kernel-bin
	app-backup/borgmatic
	net-misc/nextcloud-client
	app-admin/keepassxc
	gui-apps/input-remapper
	sys-boot/sdboot-up
	sys-kernel/modprobed-db
	media-sound/strawberry
"
