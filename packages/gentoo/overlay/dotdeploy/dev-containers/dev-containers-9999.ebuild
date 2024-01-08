EAPI=8

DESCRIPTION="dev/containers module meta package."
HOMEPAGE="https://gitlab.com/DonHugo/dotfiles"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	app-containers/podman
	app-containers/podman-compose
	app-containers/distrobox
"
