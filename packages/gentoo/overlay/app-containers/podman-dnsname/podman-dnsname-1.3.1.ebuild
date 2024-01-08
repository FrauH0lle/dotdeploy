 # Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module git-r3

DESCRIPTION="Name resolution for containers"
HOMEPAGE="https://github.com/containers/dnsname"
EGIT_REPO_URI="https://github.com/containers/dnsname.git"
EGIT_COMMIT="18822f9a4fb35d1349eb256f4cd2bfd372474d84"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="net-dns/dnsmasq"

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	install -vDm 755 "${D}/usr/libexec/cni/dnsname" -t "${D}/opt/cni/bin/"
}
