# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="atomic-registries - Parses a global YAML registry file"
HOMEPAGE="https://github.com/projectatomic/registries"
KEYWORDS=""

if [[ ${PV} == *9999* ]]; then
    EGIT_REPO_URI="${HOMEPAGE}.git"
    EGIT_CHECKOUT_DIR=${S}
    inherit git-r3
else
    SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
    KEYWORDS="~amd64"
fi

LICENSE="LGPL-2"
SLOT="0"

IUSE=""

DEPEND="
dev-go/go-md2man
dev-python/setuptools[${PYTHON_USEDEP}]
"
RDEPEND="
"
PATCHES=

RESTRICT="test"

python_compile() {
	distutils-r1_python_compile
	cd docs
	for f in *.md; do
		go-md2man -in ${f} -out ${f%%.md} || die
	done
}

python_install() {
	distutils-r1_python_install
	insinto /etc/containers
	newins registries.fedora registries.conf
    doman docs/*.1
	einstalldocs
}
