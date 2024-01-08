EAPI=8

DESCRIPTION="Update kernels for systemd-boot"
HOMEPAGE="https://gitlab.com/DonHugo/dotfiles"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

S="${WORKDIR}"

src_install() {
	exeinto /usr/bin
	doexe "${FILESDIR}/sdboot-up"

	insinto /etc/default
	newins "${FILESDIR}/sdboot-up.conf" sdboot-up
}
