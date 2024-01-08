# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson toolchain-funcs git-r3

DESCRIPTION="A flat theme with transparent elements for GTK 2/3/4 and GNOME Shell"
HOMEPAGE="https://github.com/jnsh/arc-theme"
EGIT_REPO_URI="https://github.com/jnsh/arc-theme.git"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE="cinnamon gnome-shell +gtk2 +gtk3 +gtk4 mate unity xfce"

SASSC_DEPEND="
	dev-lang/sassc
"

SVG_DEPEND="
	media-gfx/inkscape
	media-gfx/optipng
"

# Supports various GTK+3, GNOME Shell, and Cinnamon versions and uses
# pkg-config to determine which set of files to build. Updates will
# therefore break existing installs but there's no way around this. At
# least GTK+3 is unlikely to see a release beyond 3.24.
BDEPEND="
	>=dev-util/meson-0.56.0
	cinnamon? (
		${SASSC_DEPEND}
		gnome-extra/cinnamon
	)
	gnome-shell? (
		${SASSC_DEPEND}
		>=gnome-base/gnome-shell-3.18
	)
	gtk2? (
		${SVG_DEPEND}
	)
	gtk3? (
		${SASSC_DEPEND}
		${SVG_DEPEND}
		virtual/pkgconfig
		=x11-libs/gtk+-3.24*:3
	)
	gtk4? (
		${SASSC_DEPEND}
		${SVG_DEPEND}
	)
	xfce? (
		${SVG_DEPEND}
	)
"

# gnome-themes-standard is only needed by GTK+2 for the Adwaita
# engine. This engine is built into GTK+3.
RDEPEND="
	gtk2? (
		x11-themes/gnome-themes-standard
		x11-themes/gtk-engines-murrine
	)
"

src_configure() {
	local themes=$(
		printf "%s," \
		$(usev cinnamon) \
		$(usev gnome-shell) \
		$(usev gtk2) \
		$(usev gtk3) \
		$(usev gtk4) \
		$(usex mate metacity "") \
		$(usex unity unity) \
		$(usex xfce xfwm "")
	)

	local emesonargs=(
		-Dthemes="${themes%,}"
		-Dgtk3_version=3.24
		-Dgtk4_version=4.2 # 4.0 dropped in Gentoo, works with 4.4.
	)

	meson_src_configure
}

src_compile() {
	meson_src_compile
}
