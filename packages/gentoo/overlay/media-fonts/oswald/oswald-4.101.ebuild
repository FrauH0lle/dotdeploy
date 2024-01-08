# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_commit='dbb34644e36024fef3def6d268d30ead8f0ce113'

DESCRIPTION="Sans-serif typeface from Google by Vernon Adams"
HOMEPAGE="http://sorkintype.com"
SRC_URI="https://github.com/google/fonts/raw/${_commit}/ofl/oswald/static/Oswald-Bold.ttf -> Oswald-Bold-${PV}.ttf
		 https://github.com/google/fonts/raw/${_commit}/ofl/oswald/static/Oswald-ExtraLight.ttf -> Oswald-ExtraLight-${PV}.ttf
		 https://github.com/google/fonts/raw/${_commit}/ofl/oswald/static/Oswald-Light.ttf -> Oswald-Light-${PV}.ttf
		 https://github.com/google/fonts/raw/${_commit}/ofl/oswald/static/Oswald-Medium.ttf -> Oswald-Medium-${PV}.ttf
		 https://github.com/google/fonts/raw/${_commit}/ofl/oswald/static/Oswald-Regular.ttf -> Oswald-Regular-${PV}.ttf
		 https://github.com/google/fonts/raw/${_commit}/ofl/oswald/static/Oswald-SemiBold.ttf -> Oswald-SemiBold-${PV}.ttf
		 https://github.com/google/fonts/raw/${_commit}/ofl/oswald/OFL.txt -> ${PN}-${PV}-OFL.txt"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

src_unpack() {
	cp -r "${DISTDIR}" "${S}"
}

src_install() {
	install -dm 755 "${ED}/usr/share/fonts/TTF"
	install -m 644 Oswald-Bold-${PV}.ttf "${ED}/usr/share/fonts/TTF/Oswald-Bold.ttf"
	install -m 644 Oswald-ExtraLight-${PV}.ttf "${ED}/usr/share/fonts/TTF/Oswald-ExtraLight.ttf"
	install -m 644 Oswald-Light-${PV}.ttf "${ED}/usr/share/fonts/TTF/Oswald-Light.ttf"
	install -m 644 Oswald-Medium-${PV}.ttf "${ED}/usr/share/fonts/TTF/Oswald-Medium.ttf"
	install -m 644 Oswald-Regular-${PV}.ttf "${ED}/usr/share/fonts/TTF/Oswald-Regular.ttf"
	install -m 644 Oswald-SemiBold-${PV}.ttf "${ED}/usr/share/fonts/TTF/Oswald-SemiBold.ttf"
	install -Dm644 ${PN}-${PV}-OFL.txt "${ED}/usr/share/licenses/$PN/LICENSE"
}
