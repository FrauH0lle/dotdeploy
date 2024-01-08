# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Plasma applet that acts as a spacer between applets"
HOMEPAGE="https://github.com/psifidotos/applet-latte-spacer"
inherit git-r3
EGIT_REPO_URI="https://github.com/psifidotos/applet-latte-spacer.git"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="kde-plasma/plasma-workspace"

src_install() {
	_pkgdir="${ED}/usr/share/plasma/plasmoids/org.kde.latte.spacer"

	install -Dm644 metadata.desktop -t "$_pkgdir"
	find contents/ -type f -exec install -Dm644 "{}" "$_pkgdir/{}" \;
}
