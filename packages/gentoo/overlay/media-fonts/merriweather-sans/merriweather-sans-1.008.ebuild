# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_commit='8a1b078e3aeec6aecc856c3422898816af9b9dc7'

DESCRIPTION="A sans-serif typeface that is pleasant to read on screens by Sorkin Type Co"
HOMEPAGE="http://sorkintype.com"
SRC_URI="https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-Black.ttf -> MerriweatherSans-Black-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-Bold.ttf -> MerriweatherSans-Bold-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-BoldItalic.ttf -> MerriweatherSans-BoldItalic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-Italic.ttf -> MerriweatherSans-Italic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-Light.ttf -> MerriweatherSans-Light-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-LightItalic.ttf -> MerriweatherSans-LightItalic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-Regular.ttf -> MerriweatherSans-Regular-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/fonts/ttfs/MerriweatherSans-UltraBoldItalic.ttf -> MerriweatherSans-UltraBoldItalic-${PV}.ttf
		 https://github.com/SorkinType/Merriweather-Sans/raw/${_commit}/OFL.txt -> ${PN}-${PV}-OFL.txt"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

src_unpack() {
	cp -r "${DISTDIR}" "${S}"
}

src_install() {
	install -dm 755 "${ED}/usr/share/fonts/TTF"
	install -m 644 MerriweatherSans-Black-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-Black.ttf"
	install -m 644 MerriweatherSans-Bold-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-Bold.ttf"
	install -m 644 MerriweatherSans-BoldItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-BoldItalic.ttf"
	install -m 644 MerriweatherSans-Italic-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-Italic.ttf"
	install -m 644 MerriweatherSans-Light-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-Light.ttf"
	install -m 644 MerriweatherSans-LightItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-LightItalic.ttf"
	install -m 644 MerriweatherSans-Regular-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-Regular.ttf"
	install -m 644 MerriweatherSans-UltraBoldItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/MerriweatherSans-UltraBoldItalic.ttf"
	install -Dm644 ${PN}-${PV}-OFL.txt "${ED}/usr/share/licenses/$PN/LICENSE"
}
