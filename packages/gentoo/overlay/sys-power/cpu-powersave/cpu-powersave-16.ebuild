# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 meson

DESCRIPTION="Trivial boot service to move the system into powersave/on-demand CPU governor. From Solus Hardware configuration support"
HOMEPAGE="https://github.com/getsolus/solus-hardware-config"

EGIT_REPO_URI="https://github.com/getsolus/solus-hardware-config.git"
EGIT_COMMIT="8be032f3de22585d6a9d0364a8bd5b9fcc8d5de1"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="amd64"

PATCHES=(
	"${FILESDIR}/disable.patch"
)
