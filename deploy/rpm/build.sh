#!/bin/bash
#
# script used for building RPM packages

# get current directory
CURDIR=`pwd`

# setup RPM build space
mkdir /rpm
cd /rpm
mkdir -p BUILD RPMS/`uname -i` SOURCES SPECS SRPMS

# create rpm macro file
cat <<EOF >> ~/.rpmmacros
%_signature gpg
%_gpg_name RPM Builds <builds@avalabs.org>

%packager      RPM Builds <builds@avalabs.org>
%vendor        AVALabs
%_topdir       /rpm
EOF

# copy files into rpm build directories
cp /drone/src/build/ava /rpm/SOURCES/
cp /drone/src/build/xputtest /rpm/SOURCES/
cp /drone/src/deploy/rpm/ava.spec /rpm/SPECS/

# install system build tools
yum -y install rpm-build

# build RPM
rpmbuild -bb ava.spec
