# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/derekparker/delve"

if [[ ${PV} == *9999 ]]; then
	inherit golang-vcs
else
	DELVE_SHA="279a8a7"
	SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="A source-level debugger for the Go programming language"
HOMEPAGE="https://github.com/derekparker/delve"

LICENSE="MIT"
SLOT="0"
IUSE=""

S=${WORKDIR}/${P}/src/${EGO_PN}

RESTRICT="test"

src_compile() {
	GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" go build -ldflags="-X main.Build=${DELVE_SHA}" -o "bin/dlv" ./cmd/dlv || die
}

src_install() {
	dodoc README.md CHANGELOG.md
	dobin bin/dlv
}
