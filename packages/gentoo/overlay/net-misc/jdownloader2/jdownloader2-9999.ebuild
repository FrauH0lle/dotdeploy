# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Download manager, written in Java, for one-click hosting sites like Rapidshare and Megaupload. Uses its own updater."
HOMEPAGE="http://jdownloader.org/"

EGIT_REPO_URI="https://aur.archlinux.org/jdownloader2.git"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="amd64"

src_install() {
	install -d -m755 "$ED/opt/JDownloaderScripts"
	install -D -m755 "JDownloader" "$ED/opt/JDownloaderScripts/JDownloader"
	install -D -m755 "JDownloaderHeadless" "$ED/opt/JDownloaderScripts/JDownloaderHeadless"
	install -D -m755 "JDownloaderHeadlessCtl" "$ED/opt/JDownloaderScripts/JDownloaderHeadlessCtl"
	install -D -m755 "functions.sh" "$ED/opt/JDownloaderScripts/functions.sh"
	install -D -m755 "JDownloaderHeadlessCleanLogin" "$ED/opt/JDownloaderScripts/JDownloaderHeadlessCleanLogin"


	install -D -m644 "jdownloader.xml" "$ED/usr/share/mime/packages/jdownloader.xml"
	install -D -m644 "jdownloader.desktop" "$ED/usr/share/applications/jdownloader.desktop"
	install -D -m644 "jd-containers.desktop" "$ED/usr/share/applications/jd-containers.desktop"
	install -D -m644 "jd-container16.png" "$ED/usr/share/icons/hicolor/16x16/mimetypes/jd-container.png"
	install -D -m644 "jd-container22.png" "$ED/usr/share/icons/hicolor/22x22/mimetypes/jd-container.png"
	install -D -m644 "jd-container24.png" "$ED/usr/share/icons/hicolor/24x24/mimetypes/jd-container.png"
	install -D -m644 "jd-container32.png" "$ED/usr/share/icons/hicolor/32x32/mimetypes/jd-container.png"
	install -D -m644 "jd-container48.png" "$ED/usr/share/icons/hicolor/48x48/mimetypes/jd-container.png"
	install -D -m644 "jd-container256.png" "$ED/usr/share/icons/hicolor/256x256/mimetypes/jd-container.png"
	install -D -m644 "jdownloader16.png" "$ED/usr/share/icons/hicolor/16x16/apps/jdownloader.png"
	install -D -m644 "jdownloader22.png" "$ED/usr/share/icons/hicolor/22x22/apps/jdownloader.png"
	install -D -m644 "jdownloader24.png" "$ED/usr/share/icons/hicolor/24x24/apps/jdownloader.png"
	install -D -m644 "jdownloader32.png" "$ED/usr/share/icons/hicolor/32x32/apps/jdownloader.png"
	install -D -m644 "jdownloader48.png" "$ED/usr/share/icons/hicolor/48x48/apps/jdownloader.png"
	install -D -m644 "jdownloader256.png" "$ED/usr/share/icons/hicolor/256x256/apps/jdownloader.png"
	install -D -m644 "jdownloader.service" "$ED/usr/lib/systemd/system/jdownloader.service"
	install -d -m775 "$ED/opt/JDownloader"
	mkdir -p "$ED/usr/bin"

	ln -s "/opt/JDownloaderScripts/JDownloader"  "${ED}/usr/bin/JDownloader"
	ln -s "/opt/JDownloaderScripts/JDownloader" "${ED}/usr/bin/jdownloader"
	ln -s "/opt/JDownloaderScripts/JDownloaderHeadless" "${ED}/usr/bin/JDownloaderHeadless"
	ln -s "/opt/JDownloaderScripts/JDownloaderHeadlessCtl" "${ED}/usr/bin/JDownloaderHeadlessCtl"
	ln -s "/opt/JDownloaderScripts/JDownloaderHeadlessCleanLogin" "${ED}/usr/bin/JDownloaderHeadlessCleanLogin"
}
