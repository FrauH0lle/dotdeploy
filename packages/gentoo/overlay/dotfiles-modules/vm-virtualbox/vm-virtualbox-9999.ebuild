EAPI=8

DESCRIPTION="vm/virtualbox module meta package."
HOMEPAGE="https://gitlab.com/DonHugo/dotfiles"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="
	app-emulation/virtualbox
	app-emulation/virtualbox-additions
	app-emulation/virtualbox-extpack-oracle
"
