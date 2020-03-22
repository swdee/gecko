#!/bin/bash
#
# script used for building RPM packages

# get current directory
CURDIR=`pwd`

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

# build RPM
cd $RPMDIR/SPECS/
rpmbuild -bb ava.spec

# install RPM and test the binaries are working
yum -y localinstall $RPMDIR/RPMS/x86_64/avalabs-gecko-*.`uname -i`.rpm

# disable tests until exit codes are corrected in code
#ava --help
#xputtest --help

# copy RPM to host directory
cp $RPMDIR/RPMS/x86_64/*.rpm /tmp/hostdir/