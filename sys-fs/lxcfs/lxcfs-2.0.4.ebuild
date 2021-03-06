# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd vcs-snapshot versionator
DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/"
LICENSE="Apache-2.0"
SLOT="0"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/lxc/lxcfs.git"
	EGIT_BRANCH="master"
	inherit git-r3
	SRC_URI=""
	KEYWORDS=""
else
	# e.g. upstream is 2.0.0.beta2, we want 2.0.0_beta2
	UPSTREAM_PV=$(replace_version_separator 3 '.' )
	SRC_URI="https://github.com/lxc/lxcfs/archive/${PN}-${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

IUSE="pam"

# Omit all dbus.  Upstream appears to require it because systemd, but
# lxcfs makes no direct use of dbus.
RDEPEND="
	dev-libs/glib:2
	sys-fs/fuse
	virtual/pam
"
DEPEND="
	sys-apps/help2man
	${RDEPEND}
"
PATCHES="${FILESDIR}/${P}-fusermount-path.patch"

src_prepare() {
	default
	./bootstrap.sh || die "Failed to bootstrap configure files"
}

src_configure() {
	use pam || pamflag="--with-pamdir=none"

	# Without the localstatedir the filesystem isn't mounted correctly
	econf --localstatedir=/var ${pamflag}
}

# Test suite fails for me
# src_test() {
# 	emake tests
# 	tests/main.sh || die "Tests failed"
# }

src_install() {
	default
	dodir /var/lib/lxcfs
	newinitd "${FILESDIR}"/${P}.initd lxcfs
	systemd_dounit config/init/systemd/lxcfs.service
}

pkg_preinst() {
	# In an upgrade situation merging /var/lib/lxcfs (an empty dir)
	# fails because that is a live mountpoint when the service is
	# running.  It's unnecessary anyway so skip the action.
	[[ -d ${ROOT}/var/lib/lxcfs ]] && rm -rf ${D}/var
}
