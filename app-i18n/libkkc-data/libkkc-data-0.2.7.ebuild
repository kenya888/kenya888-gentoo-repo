# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit python-single-r1

DESCRIPTION="Matching Algorithm with Recursively Implemented StorAge"
HOMEPAGE="https://bitbucket.org/libkkc/"
SRC_URI="https://bitbucket.org/libkkc/${PN}/downloads/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}
	dev-libs/marisa[python,${PYTHON_USEDEP}]"
RDEPEND=""

pkg_setup() {
	python-single-r1_pkg_setup
}
