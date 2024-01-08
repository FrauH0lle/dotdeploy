EAPI=8

inherit xdg cmake git-r3

DESCRIPTION="A GUI management tool to make managing a Btrfs filesystem easier."
HOMEPAGE="https://gitlab.com/btrfs-assistant/btrfs-assistant"

LICENSE="GPL-3"
SLOT="0"

EGIT_REPO_URI="${HOMEPAGE}"
KEYWORDS="amd64"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtsvg:5
"
BDEPEND="${DEPEND}"
RDEPEND="
	media-fonts/noto
	sys-auth/polkit
	sys-fs/btrfs-progs
	${DEPEND}
"

pkg_postinst() {
	xdg_pkg_postinst
	elog "emerge app-backup/snapper for snapshot management"
	elog "emerge sys-fs/btrfsmaintenance for scrub, balance, trim or defrag"
}
