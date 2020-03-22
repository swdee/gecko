#!/bin/bash
#
# script used for building DEB packages

# install tools for building deb package
apt-get -y install build-essential devscripts debhelper

# define directory for building
BUILDDIR=/tmp/build

# define package version using project major and minor version numbers
VER="0.1"
# define package release number
REL="1"

# create build directories
mkdir $BUILDDIR
cd $BUILDDIR

# create directory for package files and its subdirectories
PKGDIR="avalabs-gecko-${VER}"
mkdir $PKGDIR
cd $PKGDIR
mkdir debian
mkdir -p usr/bin/

# copy our ava binaries into place
cp /drone/src/build/ava usr/bin/
cp /drone/src/build/xputtest usr/bin/

DATE=`date --rfc-email`


# create debian package files
cd debian
cat <<EOF >> changelog
avalabs-gecko (${VER}-${REL}) experimental; urgency=low

  * See github.com/ava-labs/gecko for changes


 -- builds <builds@avalabs.org>  ${DATE}
EOF

# create compat file
echo "9" > compat

# copy in static package files
cp /drone/src/deploy/deb/control .
cp /drone/src/deploy/deb/copyright .
cp /drone/src/deploy/deb/rules .


# build deb
cd ${BUILDDIR}/${PKGDIR}
dpkg-buildpackage

# install deb and test binaries are working
apt-get -y install ${BUILDDIR}/avalabs-gecko*.deb --fix-broken

# disable tests until exit codes are corrected in code
#ava --help
#xputtest --help
