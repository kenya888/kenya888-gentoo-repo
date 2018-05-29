# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/projectatomic/buildah
COMMIT=1ab80bc
inherit golang-vcs-snapshot

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="A tool which facilitates building OCI images"
HOMEPAGE="https://github.com/projectatomic/buildah"
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

# currently no choice if ostree enabled or not by USE flag, they are disabled.
IUSE="btrfs +lvm +seccomp selinux"
REQUIRED_USE="|| ( btrfs lvm )"

COMMON_DEPEND=">=app-crypt/gpgme-1.8.0:=
	>=dev-libs/libassuan-2.4.3
	btrfs? ( >=sys-fs/btrfs-progs-4.10.2 )
	lvm? ( >=sys-fs/lvm2-2.02.145-r2 )
	seccomp? ( sys-libs/libseccomp )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${COMMON_DEPEND}
dev-go/go-md2man
dev-libs/glib
"
RDEPEND="${COMMON_DEPEND}
app-emulation/skopeo
app-emulation/runc[seccomp?]
"

PATCHES=(
       "${FILESDIR}"/01_selinuxwomcs.patch
)

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
	if use selinux ; then
		BUILDTAGS="${BUILDTAGS} selinux"
	fi
	if [[ ${PV} == *9999* ]]; then
        COMMIT="$(git rev-parse --short HEAD)"
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
