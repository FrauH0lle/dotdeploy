# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_commit='1f5576c4fe32a29073a64f5ba39d5a684a08fbe9'

DESCRIPTION="Gelasio is designed to be metrics compatible with Georgia in its Regular, Bold, Italic and Bold Italic weights"
HOMEPAGE="http://sorkintype.com"
SRC_URI="https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-Bold.ttf -> Gelasio-Bold-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-BoldItalic.ttf -> Gelasio-BoldItalic-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-Italic.ttf -> Gelasio-Italic-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-Medium.ttf -> Gelasio-Medium-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-MediumItalic.ttf -> Gelasio-MediumItalic-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-Regular.ttf -> Gelasio-Regular-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-SemiBold.ttf -> Gelasio-SemiBold-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/fonts/ttf/Gelasio-SemiBoldItalic.ttf -> Gelasio-SemiBoldItalic-${PV}.ttf
		 https://github.com/SorkinType/Gelasio/raw/${_commit}/OFL.txt -> ${PN}-${PV}-OFL.txt"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

src_unpack() {
	cp -r "${DISTDIR}" "${S}"
}

src_install() {
	install -dm 755 "${ED}/usr/share/fonts/TTF"
	install -m 644 Gelasio-Bold-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-Bold.ttf"
	install -m 644 Gelasio-BoldItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-BoldItalic.ttf"
	install -m 644 Gelasio-Italic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-Italic.ttf"
	install -m 644 Gelasio-Medium-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-Medium.ttf"
	install -m 644 Gelasio-MediumItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-MediumItalic.ttf"
	install -m 644 Gelasio-Regular-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-Regular.ttf"
	install -m 644 Gelasio-SemiBold-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-SemiBold.ttf"
	install -m 644 Gelasio-SemiBoldItalic-${PV}.ttf "${ED}/usr/share/fonts/TTF/Gelasio-SemiBoldItalic.ttf"
	install -Dm644 ${PN}-${PV}-OFL.txt "${ED}/usr/share/licenses/$PN/LICENSE"
}
