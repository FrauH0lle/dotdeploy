EAPI=8

DESCRIPTION="base module meta package."
HOMEPAGE="https://gitlab.com/DonHugo/dotfiles"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

# Necessities
RDEPEND="
	dev-vcs/git
	app-misc/jq
"

# LTS Kernel
RDEPEND="
	${RDEPEND}
	=sys-kernel/gentoo-kernel-bin-6.1*
"

# Cron daemon
RDEPEND="
	${RDEPEND}
	sys-process/cronie
"

# SSH
RDEPEND="
	${RDEPEND}
	net-fs/sshfs
"

# File systems
RDEPEND="
	${RDEPEND}
	sys-fs/btrfs-progs
	sys-fs/dosfstools
	sys-fs/exfatprogs
	sys-fs/mtools
	sys-fs/ntfs3g
"

# Portage tools
RDEPEND="
	${RDEPEND}
	app-eselect/eselect-repository
	app-portage/smart-live-rebuild
	app-portage/gentoolkit
	app-portage/eix
	app-portage/genlop
"

# mold linker
RDEPEND="
	${RDEPEND}
    sys-devel/mold
"

# System tools
RDEPEND="
	${RDEPEND}
	sys-process/htop
	app-editors/nano
	sys-power/cpupower
	media-fonts/terminus-font
"
