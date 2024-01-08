# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

_name=urw-base35-fonts

DESCRIPTION="(URW)++ base 35 font set"
HOMEPAGE="https://github.com/ArtifexSoftware/urw-base35-fonts"
SRC_URI="https://github.com/ArtifexSoftware/${_name}/archive/refs/tags/${PV}.tar.gz -> ${_name}-${PV}.tar.gz"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="amd64 x86"

S="${WORKDIR}/${_name}-${PV}"

src_install() {
	local _config _config_path

	install -vDm 644 fonts/*.otf -t "${ED}/usr/share/fonts/${PN}"
	install -vDm 644 appstream/*.xml -t "${ED}/usr/share/metainfo"

	install -vdm 755 "${ED}/etc/fonts/conf.avail/"
	for _config in fontconfig/*.conf; do
		_config_path="${ED}/etc/fonts/conf.avail/69-${_config##*/}"
		install -vDm 644 "${_config}" "${_config_path}"
	done
}
