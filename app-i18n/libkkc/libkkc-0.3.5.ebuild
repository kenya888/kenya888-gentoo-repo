# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
VALA_MIN_API_VERSION="0.16"

inherit eutils vala

DESCRIPTION="Japanese Kana Kanji conversion library"
HOMEPAGE="https://bitbucket.org/libkkc/libkkc/wiki/Home https://github.com/ueno/libkkc"
SRC_URI="https://github.com/ueno/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="introspection vala"

RDEPEND="dev-libs/libgee:0.8
	dev-libs/json-glib
	dev-libs/marisa
	introspection? ( dev-libs/gobject-introspection )"
DEPEND="${RDEPEND}
	dev-libs/gobject-introspection
	vala? ( $(vala_depend) )"

src_prepare() {
	use vala && vala_src_prepare
	sed -i -e '/^SUBDIRS/s: tests::' Makefile.in || die
}

src_configure() {
	econf \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable vala)
}

src_install() {
	default
	prune_libtool_files
}
