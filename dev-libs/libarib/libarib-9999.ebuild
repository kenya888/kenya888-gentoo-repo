# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_BRANCH=master
EGIT_REPO_URI="https://github.com/stz2012/libarib25.git"
inherit git-r3 cmake-utils

SLOT="0"

DESCRIPTION="ARIB STD-B25 test program for checking specs"

KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="
	sys-apps/pcsc-lite
	dev-vcs/git
"
DEPEND="
	${RDEPEND}
"
