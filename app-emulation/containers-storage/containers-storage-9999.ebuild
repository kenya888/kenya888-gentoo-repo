# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/containers/storage
COMMIT=
inherit golang-vcs-snapshot

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="A Go library which aims to provide methods for storing filesystem layers, container images, and containers. A containers-storage"
HOMEPAGE="https://github.com/containers/storage"
KEYWORDS=""

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="${HOMEPAGE}.git"
	EGIT_CHECKOUT_DIR=${S}
    inherit git-r3
else
	SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
    KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+btrfs +lvm +overlay"
REQUIRED_USE="|| ( btrfs lvm overlay )"

COMMON_DEPEND="
	btrfs? ( >=sys-fs/btrfs-progs-4.0.1 )
	lvm? ( >=sys-fs/lvm2-2.02.145 )
"
DEPEND="${COMMON_DEPEND}
	dev-go/go-md2man
"
RDEPEND="${COMMON_DEPEND}"

PATCHES=

RESTRICT="test"

src_compile() {
	local BUILDTAGS="containers_image_ostree_stub"
	if ! use btrfs ; then
		BUILDTAGS="${BUILDTAGS} exclude_graphdriver_btrfs"
	fi
	if ! use lvm ; then
		BUILDTAGS="${BUILDTAGS} exclude_graphdriver_devicemapper"
	fi
	if ! use overlay ; then
		BUILDTAGS="${BUILDTAGS} exclude_graphdriver_overlay"
	fi
	if [[ ${PV} == *9999* ]]; then
		COMMIT="$(git rev-parse --short HEAD)"
	fi
	set -- env GOPATH="${WORKDIR}/${P}" \
		go build -ldflags "-X main.gitCommit=${COMMIT}" \
		-gcflags "${GOGCFLAGS}" -tags "${BUILDTAGS}" \
		-o containers-storage ./cmd/containers-storage
	echo "$@"
	"$@" || die
	cd docs
	for f in *.md; do
		go-md2man -in ${f} -out ${f%%.md}.1 || die
	done
}

src_install() {
	dobin containers-storage
	doman docs/*.1
	insinto /etc/containers
	doins storage.conf
	einstalldocs
}
