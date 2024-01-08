# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Arc KDE customization"
HOMEPAGE="https://github.com/PapirusDevelopmentTeam/arc-kde/"
inherit git-r3
EGIT_REPO_URI="https://github.com/PapirusDevelopmentTeam/${PN}.git"
LICENSE="GPL-3+ CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="konversation yakuake"
RESTRICT="primaryuri"

RDEPEND="x11-themes/kvantum"

src_install() {
	einstalldocs

	local -r themes=(
		aurorae
		color-schemes
		konsole
		$(usev konversation)
		Kvantum
		plasma
		wallpapers
		$(usev yakuake)
	)

	emake DESTDIR="${ED}" THEMES="${themes[*]}" install

	find "${ED}/usr/share" \( -name "AUTHORS" -o -name "LICENSE" \) -delete \
		|| die "the cleaning has failed"
}
