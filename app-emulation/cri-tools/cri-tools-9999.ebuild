# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/kubernetes-incubator/cri-tools
COMMIT=4403b8052e4fff648f840cbf392497269ca3be74
inherit golang-vcs-snapshot

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="CLI and validation tools for Container Runtime Interface"
HOMEPAGE="https://github.com/kubernetes-incubator/cri-tools"
KEYWORDS=""

if [[ ${PV} == *9999* ]]; then
    EGIT_REPO_URI="${HOMEPAGE}.git"
    EGIT_CHECKOUT_DIR=${S}
    inherit git-r3
else
    SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> cri-o.tar.gz"
    KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
#Currently critest is not supported due to test is set to RESTRICTED
#IUSE="critest"

DEPEND="
dev-go/go-md2man
"
RDEPEND="${DEPEND}
"

PATCHES=

RESTRICT="test"

src_compile() {

	if [[ ${PV} == *9999* ]]; then
		COMMIT="$(git rev-parse HEAD)"
    fi

	set -- env GOPATH="${WORKDIR}/${P}" \
		go build -o crictl ./cmd/crictl

    echo "$@"
	"$@" || die

#Currently critest is not supported due to test is set to RESTRICTED
#	if use critest ; then
#		set -- env GOPATH="${WORKDIR}/${P}" \
#			go build -o critest ./cmd/critest
#
#		echo "$@"
#		"$@" || die
#	fi

	go-md2man -in docs/crictl.md -out docs/crictl.1 || die
}

src_install() {
	dobin crictl
#	if use critest ; then
#		dobin critest
#	fi
	doman docs/crictl.1
}
