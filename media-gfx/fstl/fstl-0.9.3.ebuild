# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"
DESCRIPTION="The fastest STL file viewer"
HOMEPAGE="http://www.mattkeeter.com/projects/fstl"
KEYWORDS="~amd64 ~x86"
IUSE="debug"
LICENSE="MIT"

SRC_URI="https://github.com/mkeeter/${PN}/archive/v${PV}.tar.gz"

inherit qmake-utils eutils

RDEPEND="
    dev-qt/qtcore:5
    dev-qt/qtgui:5
    dev-qt/qtopengl:5
    dev-qt/qtwidgets:5
"
DEPEND="
    ${RDEPEND}
"
src_configure() {
    eqmake5 qt/fstl.pro
}

src_install() {
    emake install INSTALL_ROOT="${D}"
}
