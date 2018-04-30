# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/projectatomic/libpod
COMMIT=888927a
inherit golang-vcs-snapshot bash-completion-r1

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="podman - Manage Pods, Containers and Container Images"
HOMEPAGE="https://github.com/projectatomic/libpod"
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
	selinux? ( sec-policy/selinux-virt )
"
DEPEND="${COMMON_DEPEND}
	dev-go/go-md2man
	dev-libs/glib
"
RDEPEND="${COMMON_DEPEND}
	app-emulation/skopeo
	app-emulation/buildah[seccomp?]
	app-emulation/runc[seccomp?]
	app-emulation/conmon
	app-emulation/atomic-registries
	net-misc/cni-plugins
	net-firewall/iptables[conntrack,nftables]
"

PATCHES=(
	"${FILESDIR}"/01_selinuxwomcs.patch
)

RESTRICT="test"

src_compile() {
	local BUILDTAGS="containers_image_ostree_stub"
	local BUILD_INFO="$(date +%s)"

	if ! use btrfs ; then
		BUILDTAGS="${BUILDTAGS} exclude_graphdriver_btrfs"
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
		go build -ldflags "-X main.gitCommit=${COMMIT} -X main.buildInfo=${BUILD_INFO}" \
		-gcflags "${GOGCFLAGS}" -tags "${BUILDTAGS}" \
		-o podman ./cmd/podman
	echo "$@"
	"$@" || die
	cd docs
	for f in *.1.md; do
		go-md2man -in ${f} -out ${f%%.md} || die
	done
}

src_install() {
	dobin podman
	insinto /usr/share/containers
	doins libpod.conf seccomp.json
	insinto /etc/containers
	doins libpod.conf
	insinto /etc/cni/net.d
	doins cni/87-podman-bridge.conflist
	dobashcomp completions/bash/podman
	doman docs/*.1
	einstalldocs
}
