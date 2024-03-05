# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_SETUPTOOLS="rdepend"

inherit distutils-r1 systemd git-r3

DESCRIPTION="A tool to change and program the mapping of your input device buttons"
HOMEPAGE="https://github.com/sezanzeb/input-remapper"
EGIT_REPO_URI="https://github.com/sezanzeb/input-remapper.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="x11-libs/gtk+:3
		 x11-apps/xmodmap
		 x11-libs/gtksourceview:4
		 $(python_gen_cond_dep '
		   dev-python/pygobject[${PYTHON_USEDEP}]
		   dev-python/pydbus[${PYTHON_USEDEP}]
		   dev-python/pydantic[${PYTHON_USEDEP}]
		   dev-python/evdev[${PYTHON_USEDEP}]
		   dev-python/setuptools[${PYTHON_USEDEP}]
		 ')"

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install
}
