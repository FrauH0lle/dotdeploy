# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_font='cantora'
_group='impallari'

DESCRIPTION="Cantora ('Singer' in Spanish) is a friendly semi-formal, semi-condensed, semi–sans-serif font"
HOMEPAGE="https://fonts.google.com/specimen/Cantora+One"
SRC_URI="https://fonts.google.com/download?family=Cantora%20One -> Cantora_One.zip"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

BDEPEND="app-arch/unzip"

S="${WORKDIR}"
src_install() {
	install -dm755 "${ED}/usr/share/fonts/TTF/${_group}"
	install -Dpm644 *.ttf "${ED}/usr/share/fonts/TTF/${_group}"

	install -dm755 "${ED}/usr/share/licenses/${PN}/"
	install -Dpm644 OFL.txt "${ED}/usr/share/licenses/${PN}/"
}
