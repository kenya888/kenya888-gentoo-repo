# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN=github.com/projectatomic/skopeo
COMMIT=0270e56
inherit golang-vcs-snapshot

S="${WORKDIR}/${P}/src/${EGO_PN}"

DESCRIPTION="Command line utility foroperations on container images and image repositories"
HOMEPAGE="https://github.com/projectatomic/skopeo"
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
IUSE="+btrfs +lvm"
REQUIRED_USE="|| ( btrfs lvm )"

COMMON_DEPEND=">=app-crypt/gpgme-1.5.5:=
	>=dev-libs/libassuan-2.4.3
	btrfs? ( >=sys-fs/btrfs-progs-4.0.1 )
	lvm? ( >=sys-fs/lvm2-2.02.145 )
"
DEPEND="${COMMON_DEPEND}
	dev-go/go-md2man
"
RDEPEND="${COMMON_DEPEND}
	app-emulation/containers-storage
"

PATCHES=


RESTRICT="test"

src_compile() {
	local BUILDTAGS="containers_image_ostree_stub"
	if [[ ${PV} == *9999* ]]; then
		COMMIT="$(git rev-parse --short HEAD)"
	fi
	set -- env GOPATH="${WORKDIR}/${P}" \
		go build -ldflags "-X main.gitCommit=${COMMIT}" \
		-gcflags "${GOGCFLAGS}" -tags "${BUILDTAGS}" \
		-o skopeo ./cmd/skopeo
	echo "$@"
	"$@" || die
	cd docs
	for f in *.1.md; do
		go-md2man -in ${f} -out ${f%%.md} || die
	done
}

src_install() {
	dobin skopeo
	doman docs/*.1
	insinto /etc/containers
	newins default-policy.json policy.json
	insinto /etc/containers/registries.d
	doins default.yaml
	dodir /var/lib/atomic/sigstore
	einstalldocs
}
