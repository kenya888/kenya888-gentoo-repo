# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/kubernetes-incubator/cri-o
COMMIT=e2bb6aaa7931607820b85b8020f47d19efb4e0a3
inherit golang-vcs-snapshot toolchain-funcs

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="OCI container runtime monitor"
HOMEPAGE="https://github.com/kubernetes-incubator/cri-o"
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

DEPEND="
dev-libs/glib
"
RDEPEND="${DEPEND}
"

PATCHES=

RESTRICT="test"

src_compile() {

	if [[ ${PV} == *9999* ]]; then
        COMMIT="$(git rev-parse HEAD)"
    fi

	local BUILD_INFO="$(date +%s)"

	set -- env GOPATH="${WORKDIR}/${P}" \
		go build -i -ldflags "-s -w -X main.buildInfo=${BUILD_INFO} -X main.gitCommit=${COMMIT}" \
		-o crio-config ./cmd/crio-config

    echo "$@"
	"$@" || die

	"${S}/crio-config" || die
    mv config.h conmon/config.h || die

	local GIT_COMMIT=${COMMIT}
	local VERSION="$(sed -n -e 's/^const Version = "\([^"]*\)"/\1/p' version/version.go)"
	local CFLAGS="${CFLAGS} $(pkg-config --cflags glib-2.0) -DVERSION=\"${VERSION}\" -DGIT_COMMIT=\"${GIT_COMMIT}\""
    local LIB="$(pkg-config --libs glib-2.0)"
    $(tc-getCC) -o ${S}/conmon/${PN} ${S}/conmon/config.h ${S}/conmon/cmsg.c ${S}/conmon/conmon.c ${CFLAGS} "${LIB}" || die

}

src_install() {
	exeinto /usr/libexec/crio
	doexe conmon/conmon
}
