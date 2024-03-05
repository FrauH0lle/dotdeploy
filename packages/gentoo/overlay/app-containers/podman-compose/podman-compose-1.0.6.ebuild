# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..12} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Run docker-compose files without root with podman"
HOMEPAGE="https://pypi.org/project/podman-compose https://github.com/containers/podman-compose"

SRC_URI="https://github.com/containers/podman-compose/archive/v${PV}.tar.gz"
KEYWORDS="amd64"

LICENSE="GPL-2"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND=""
RDEPEND="
	${DEPEND}
	app-containers/podman
	app-containers/podman-dnsname
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
"
