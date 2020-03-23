#!/bin/bash
#
# script used for building DEB packages

# install tools for building deb package
apt-get -y install build-essential devscripts debhelper

# define directory for building
BUILDDIR=/tmp/build

# read in an set environment variables used in ava.spec file for defining
# the version and release numbers
#
# drone passes $GIT_TAG to us which will contain the git tag name which
# must be in semantic version format 1.2.3 (major.minor.patch), or it will
# be blank if no tag was set in which case the building is a nightly
# snapshot
if [ "${GIT_TAG}" == "" ]; then
    # nightly snapshot
    DATE=`date "+%Y%m%d"`
    RPM_VER="0.0"
    RPM_REL="0.${DATE}git${GIT_COMMIT}"
else
    # tagged build
    # split version components from tag
    MAJOR=${GIT_TAG:0:1}
    MINOR=${GIT_TAG:2:1}
    PATCH=${GIT_TAG:4:1}
    RPM_VER="${MAJOR}.${MINOR}"
    RPM_REL="${PATCH}"
fi

# define package version using project major and minor version numbers
VER="${RPM_VER}"
# define package release number
REL="${RPM_REL}"

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

# copy built rpm to mounted store volume
cp ${BUILDDIR}/avalabs-gecko*.{dsc,gz,buildinfo,changes,deb} /store/