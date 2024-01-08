# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_commit='06e56b5a24d80a4a1ac94a71a0a05a98b5d02ef5'

DESCRIPTION="A typeface that is pleasant to read on screens by Sorkin Type Co"
HOMEPAGE="http://sorkintype.com"
SRC_URI="https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-Black.ttf -> Merriweather-Black-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-BlackItalic.ttf -> Merriweather-BlackItalic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-Bold.ttf -> Merriweather-Bold-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-BoldItalic.ttf -> Merriweather-BoldItalic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-Italic.ttf -> Merriweather-Italic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-Light.ttf -> Merriweather-Light-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-LightItalic.ttf -> Merriweather-LightItalic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/fonts/ttfs/Merriweather-Regular.ttf -> Merriweather-Regular-${PV}.ttf
		 https://github.com/SorkinType/Merriweather/raw/${_commit}/OFL.txt -> ${PN}-${PV}-OFL.txt"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

src_unpack() {
	cp -r "${DISTDIR}" "${S}"
}

src_install() {
	install -dm 755 "${ED}/usr/share/fonts/TTF"
	install -m 644 Merriweather-Black-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-Black.ttf"
	install -m 644 Merriweather-BlackItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-BlackItalic.ttf"
	install -m 644 Merriweather-Bold-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-Bold.ttf"
	install -m 644 Merriweather-BoldItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-BoldItalic.ttf"
	install -m 644 Merriweather-Italic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-Italic.ttf"
	install -m 644 Merriweather-Light-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-Light.ttf"
	install -m 644 Merriweather-LightItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-LightItalic.ttf"
	install -m 644 Merriweather-Regular-${PV}.ttf "${ED}/usr/share/fonts/TTF/Merriweather-Regular.ttf"
	install -Dm644 ${PN}-${PV}-OFL.txt "${ED}/usr/share/licenses/$PN/LICENSE"
}
