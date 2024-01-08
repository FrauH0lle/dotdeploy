# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Dynamic wallpaper plugin for KDE Plasma"
HOMEPAGE="https://github.com/zzag/plasma5-wallpapers-dynamic"
SRC_URI="https://github.com/zzag/plasma5-wallpapers-dynamic/archive/refs/tags/3.3.9.tar.gz"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
		kde-frameworks/plasma
		dev-qt/qtpositioning[qml,geoclue]
		media-libs/libheif
		media-libs/libexif
"
DEPEND="${RDEPEND}"

pkgname=plasma5-wallpapers-dynamic
S="${WORKDIR}/${pkgname}-$PV"
