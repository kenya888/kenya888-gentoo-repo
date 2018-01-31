# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/projectatomic/buildah
COMMIT=6bad262
inherit golang-vcs-snapshot

DESCRIPTION="A tool which facilitates building OCI images"
HOMEPAGE="https://github.com/projectatomic/buildah"
SRC_URI="https://github.com/projectatomic/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# currently no choice if selinux and ostree enabled or not by USE flag, they are disabled.
IUSE="btrfs +lvm +seccomp"
#IUSE="btrfs lvm +seccomp +doc selinux ostree"
REQUIRED_USE="|| ( btrfs lvm )"

COMMON_DEPEND=">=app-crypt/gpgme-1.8.0:=
	>=dev-libs/libassuan-2.4.3
	btrfs? ( >=sys-fs/btrfs-progs-4.10.2 )
	lvm? ( >=sys-fs/lvm2-2.02.145-r2 )
    seccomp? ( sys-libs/libseccomp )
"
DEPEND="${COMMON_DEPEND}
dev-go/go-md2man
dev-libs/glib
"
RDEPEND="${COMMON_DEPEND}
app-emulation/skopeo
seccomp? ( app-emulation/runc[seccomp?] )
"

PATCHES=

S="${WORKDIR}/${P}/src/${EGO_PN}"

RESTRICT="test"

src_compile() {
	local BUILDTAGS="containers_image_ostree_stub"
	if ! use btrfs ; then
		BUILDTAGS="${BUILDTAGS} btrfs_noversion"
	fi
	if ! use lvm ; then
		BUILDTAGS="${BUILDTAGS} libdm_no_deferred_remove"
	fi
	if use seccomp ; then
		BUILDTAGS="${BUILDTAGS} seccomp"
	fi
	set -- env GOPATH="${WORKDIR}/${P}" \
		go build -ldflags "-X main.gitCommit=${COMMIT}" \
		-gcflags "${GOGCFLAGS}" -tags "${BUILDTAGS}" \
		-o buildah ./cmd/buildah
	echo "$@"
	"$@" || die
	cd docs
	for f in *.md; do
		go-md2man -in ${f} -out ${f%%.md}.1 || die
	done
}

src_install() {
	dobin buildah
    doman docs/*.1
	einstalldocs
}
