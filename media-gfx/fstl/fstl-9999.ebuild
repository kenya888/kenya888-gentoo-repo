# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"
DESCRIPTION="The fastest STL file viewer"
KEYWORDS="~amd64 ~x86"
IUSE="debug"
LICENSE="MIT"

inherit cmake-utils eutils

case ${PV} in
    9999)
    EGIT_REPO_URI="https://github.com/mkeeter/${PN}.git"
    EGIT_BRANCH="master"
	BUILD_TYPE="live"
	inherit git-r3
    ;;
    *)
	SRC_URI="https://github.com/mkeeter/${PN}/archive/v${PV}.tar.gz"
	BUILD_TYPE="release"
	;;
esac

RDEPEND="
	dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtopengl
	dev-qt/qtwidgets
"
DEPEND="
	${RDEPEND}
"

src_unpack() {
    case ${BUILD_TYPE} in
	    live) git-r3_src_unpack ;;
		release) default ;;
	esac
}
