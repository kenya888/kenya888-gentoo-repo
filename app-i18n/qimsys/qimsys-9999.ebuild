# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit eutils git-r3 multilib qmake-utils gnome2-utils
IUSE="+X gtk gtk3 +anthy +socialime googleime sdk tests examples"

DESCRIPTION="Qt based input method system for Linux"
HOMEPAGE="http://code.google.com/p/qimsys"
EGIT_REPO_URI="git://git.qt-users.jp/codereview/qimsys.git"
SRC_URI=""

# Minimal supported version of Qt.
QT_VER="5.6.0"

RDEPEND="
	>=dev-qt/qtdeclarative-${QT_VER}:5
	>=dev-qt/qtgui-${QT_VER}:5
	>=dev-qt/qtdbus-${QT_VER}:5
	gtk? (
		x11-libs/gtk+:2
		dev-libs/glib
		dev-libs/dbus-glib
	)
	gtk3? (
		x11-libs/gtk+:3
		dev-libs/glib
		dev-libs/dbus-glib
	)
	anthy? (
		app-i18n/anthy
	)
	X? (
		x11-libs/libX11
	)
"

DEPEND="
	sdk? (
		app-doc/doxygen
	)
	x11-proto/xproto
	dev-vcs/git
	${RDEPEND}"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~x86 ~amd64"

pkg_setup() {

	if use !anthy && use !socialime && use !googleime; then
		eerror "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
		eerror ""
		eerror "C A U T I O N ! !"
		eerror ""
		eerror "You must set at least one of IMengines, anthy, socialime or googleime"
		eerror ""
		eerror "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
		die
	fi

	if use !X && use !gtk && !gtk3; then
		eerror "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
		eerror ""
		eerror "C A U T I O N ! !"
		eerror ""
		eerror "You must set at least one of IMmodules, X, gtk or gtk3"
		eerror ""
		eerror "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
		die
	fi
}

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	cd "${S}"
	# use qmake to configure
	conflist="QIMSYS_CONFIG+=no-qt4immodule"
	use !X && conflist="${conflist} QIMSYS_CONFIG+=no-xim"
	use !gtk && conflist="${conflist} QIMSYS_CONFIG+=no-dbus QIMSYS_CONFIG+=no-gtk2immodule"
	use !anthy && conflist="${conflist} QIMSYS_CONFIG+=no-anthy"
	use !socialime && conflist="${conflist} QIMSYS_CONFIG+=no-socialime"
	use !googleime && conflist="${conflist} QIMSYS_CONFIG+=no-googleime"
	use sdk && conflist="${conflist} QIMSYS_CONFIG+=sdk"
	use examples && conflist="${conflist} QIMSYS_CONFIG+=examples"
	use tests && conflist="${conflist} QIMSYS_CONFIG+=tests"

	eqmake5 \
	-r \
	PREFIX=/usr \
	QT_IM_MODULE_DIR="$(qt5_get_libdir)/plugins/platforminputcontexts"
	GTK2_IM_MODULE_DIR="`pkg-config --variable=libdir gtk+-2.0`/gtk-2.0/`pkg-config --variable=gtk_binary_version gtk+-2.0`/immodules" \
	GTK3_IM_MODULE_DIR="`pkg-config --variable=libdir gtk+-3.0`/gtk-3.0/`pkg-config --variable=gtk_binary_version gtk+-3.0`/immodules" \
	${conflist}
}

pkg_postinst() {
	use gtk && gnome2_query_immodules_gtk2
	use gtk3 && gnome2_query_immodules_gtk3
}

pkg_postrm() {
	pkg_postinst
}
