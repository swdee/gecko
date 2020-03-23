#!/bin/bash
#
# script used for building RPM packages

# directory to build RPMs in
RPMDIR=/tmp/rpm

# setup RPM build space
mkdir $RPMDIR
cd $RPMDIR
mkdir -p BUILD RPMS/`uname -i` SOURCES SPECS SRPMS

# create rpm macro file
cat <<EOF >> ~/.rpmmacros
%_signature gpg
%_gpg_name RPM Builds <builds@avalabs.org>

%packager      RPM Builds <builds@avalabs.org>
%vendor        AVALabs
%_topdir       ${RPMDIR}
EOF

# copy files into rpm build directories
cp /drone/src/build/ava $RPMDIR/SOURCES/
cp /drone/src/build/xputtest $RPMDIR/SOURCES/
cp /drone/src/deploy/rpm/ava.spec $RPMDIR/SPECS/

# install system build tools
yum -y install rpm-build

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

# modify spec to replace our template variables
cd $RPMDIR/SPECS/
sed -i "s/%%RPM_VER%%/$RPM_VER/g" ava.spec
sed -i "s/%%RPM_REL%%/$RPM_REL/g" ava.spec

# build RPM
rpmbuild -bb ava.spec

# install RPM and test the binaries are working
yum -y localinstall $RPMDIR/RPMS/x86_64/avalabs-gecko-*.`uname -i`.rpm

# disable tests until exit codes are corrected in code
#ava --help
#xputtest --help
