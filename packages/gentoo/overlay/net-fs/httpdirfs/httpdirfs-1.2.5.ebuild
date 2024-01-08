EAPI=8

inherit toolchain-funcs

DESCRIPTION="Filesystem to mount HTTP directory listings, with a permanent cache"
HOMEPAGE="https://github.com/fangfufu/httpdirfs"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/fangfufu/${PN}.git"
else
	SRC_URI="https://github.com/fangfufu/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64"
fi

RESTRICT="test"
LICENSE="GPL-3"
SLOT="0"
# Doc generation fails
# uses app-doc/doxygen[dot]
# IUSE="doc"

BDEPEND="app-doc/doxygen"
DEPEND="
	dev-libs/expat
	dev-libs/gumbo
	net-misc/curl
	sys-fs/e2fsprogs
	sys-fs/fuse
"
RDEPEND="${DEPEND}"

src_compile () {
	emake CC="$(tc-getCC)" man
	emake CC="$(tc-getCC)" doc
	emake CC="$(tc-getCC)"
}

src_install() {
	emake prefix="${D}/usr" install
}
