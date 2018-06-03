# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_5 )
inherit distutils-r1

DESCRIPTION="Python implementation of the Varlink protocol"
HOMEPAGE="https://varlink.org/python/"
SRC_URI=""

KEYWORDS=""

S="${WORKDIR}/python-${PV}"

if [[ ${PV} == *9999* ]]; then
    EGIT_REPO_URI="https://github.com/varlink/python.git"
    EGIT_CHECKOUT_DIR=${S}
    inherit git-r3
else
    SRC_URI="https://github.com/varlink/python/archive/${PV}.tar.gz -> ${P}.tar.gz"
    KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="
	dev-libs/libvarlink
"
RDEPEND="${DEPEND}"
