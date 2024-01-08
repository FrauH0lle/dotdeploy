EAPI=8

DESCRIPTION="Extended font collection meta package, ported from Infinality."
HOMEPAGE="https://aur.archlinux.org/packages/fonts-meta-extended-lt/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="media-libs/fontconfig
		 media-fonts/noto
		 media-fonts/courier-prime
		 media-fonts/dejavu
		 media-fonts/heuristica
		 media-fonts/liberation-fonts
		 media-fonts/symbola
		 media-fonts/cantarell
		 media-fonts/urw-fonts
		 media-fonts/tex-gyre
		 media-fonts/crosextrafonts-caladea
		 media-fonts/crosextrafonts-carlito
		 media-fonts/droid
		 media-fonts/gelasio-ib
		 media-fonts/impallari-cantora
		 media-fonts/merriweather
		 media-fonts/merriweather-sans
		 media-fonts/open-sans
		 media-fonts/oswald
		 media-fonts/quintessential
		 media-fonts/signika
		 media-fonts/ubuntu-font-family"

src_unpack() {
	mkdir -p "${S}"
	cp "${FILESDIR}/30-infinality-aliases.conf" "${S}/30-infinality-aliases.conf"
}

src_prepare() {
	eapply "${FILESDIR}/pdf-aliases.patch"
	eapply_user
}

src_install() {
	install -Dm644 -t "${ED}/etc/fonts/conf.avail" "${S}/30-infinality-aliases.conf"
}
