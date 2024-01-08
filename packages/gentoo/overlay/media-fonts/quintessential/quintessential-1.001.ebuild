# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_commit='883939708704a19a295e0652036369d22469e8dc'

DESCRIPTION="Calligraphic typeface from Google by Brian J. Bonislawsky"
HOMEPAGE="http://sorkintype.com"
SRC_URI="https://github.com/google/fonts/raw/${_commit}/ofl/quintessential/Quintessential-Regular.ttf -> Quintessential-Regular-${PV}.ttf"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

src_unpack() {
	cp -r "${DISTDIR}" "${S}"
}

src_install() {
	install -dm 755 "${ED}/usr/share/fonts/TTF"
	install -m 644 Quintessential-Regular-${PV}.ttf "${ED}/usr/share/fonts/TTF/Quintessential-Regular.ttf"
}
