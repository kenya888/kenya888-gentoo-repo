# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/kubernetes-incubator/cri-o
COMMIT=e2bb6aaa7931607820b85b8020f47d19efb4e0a3
inherit golang-vcs-snapshot toolchain-funcs systemd

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="CRI-O is the Kubernetes Container Runtime Interface for OCI-based containers"
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
seccomp? ( app-emulation/runc[seccomp?] )
=app-emulation/conmon-${PV}
app-emulation/skopeo
net-firewall/iptables[conntrack,nftables]
net-firewall/conntrack-tools
sys-apps/iproute2
app-emulation/cri-tools
>=net-misc/cni-plugins-0.7.0
"
PATCHES=(
	"${FILESDIR}"/01_crio-service-unit.patch
)

RESTRICT="test"

src_compile() {

	if [[ ${PV} == *9999* ]]; then
        COMMIT="$(git rev-parse HEAD)"
    fi

	local BUILD_INFO="$(date +%s)"
    local BUILDTAGS="containers_image_ostree_stub"

    if use seccomp ; then
		BUILDTAGS="${BUILDTAGS} seccomp"
	fi
	if ! use btrfs ; then
	    BUILDTAGS="${BUILDTAGS} exclude_graphdriver_btrfs"
	fi
	if ! use lvm ; then
		BUILDTAGS="${BUILDTAGS} exclude_graphdriver_devicemapper"
	fi

	set -- env GOPATH="${WORKDIR}/${P}" \
		go build -i -gcflags "${CGOCFLAGS}" -ldflags "-X main.buildInfo=${BUILD_INFO} -X main.gitCommit=${COMMIT}" -tags "${BUILDTAGS}" \
		-o crio ./cmd/crio

    echo "$@"
	"$@" || die

    ${S}/crio --config="" \
	--cgroup-manager cgroupfs --conmon /usr/libexec/crio/conmon \
	config > crio.conf

	local GIT_COMMIT=${COMMIT}
	local VERSION="$(sed -n -e 's/^const Version = "\([^"]*\)"/\1/p' version/version.go)"
	local CFLAGS="${CFLAGS} $(pkg-config --cflags glib-2.0) -DVERSION=\"${VERSION}\" -DGIT_COMMIT=\"${GIT_COMMIT}\""
    local LIB="$(pkg-config --libs glib-2.0)"
    $(tc-getCC) -o ${S}/pause/pause ${S}/pause/pause.c ${CFLAGS} "${LIB}" || die

	cd docs
	for f in *.md; do
        go-md2man -in ${f} -out ${f%%.md} || die
    done
}

src_install() {
	exeinto /usr/libexec/crio/
	doexe pause/pause
	dobin crio
	insinto /etc/crio
	doins crio.conf seccomp.json
	insinto /usr/share/oci-umount/oci-umount.d
	doins crio-umount.conf
	insinto /etc
	doins crictl.yaml
	insinto /etc/cni/net.d
	newins contrib/cni/10-crio-bridge.conf 100-crio-bridge.conf
	newins contrib/cni/99-loopback.conf 200-loopback.conf
	doman docs/*.[1-9,n,o,l]
	systemd_dounit contrib/systemd/*.service
	systemd_install_serviced "${FILESDIR}"/crio.service.conf
	einstalldocs
}
