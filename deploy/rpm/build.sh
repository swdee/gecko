#!/bin/bash
#
# script used for building RPM packages

# write passphrase to file for rpm signing
GPASS="/root/.gpass"
echo "$GPG_PASSPHRASE" > $GPASS

# import GPG key
GKEY="/root/.gkey.asc"
echo $GPG_KEY | base64 -d > $GKEY
gpg --import --batch --pinentry-mode loopback --passphrase-file=$GPASS $GKEY

# make the imported key trusted
yum -y install expect procps
KEY_ID=`gpg --list-keys --with-colons '<builds@avalabs.org>' | awk -F: '/^fpr:/ { print $10 }'`
echo "Got Key ID=${KEY_ID}"
expect -c "spawn gpg --edit-key ${KEY_ID} trust quit; send \"5\ry\r\"; expect eof"

# directory to build RPMs in
RPMDIR=/tmp/rpm

# setup RPM build space
mkdir $RPMDIR
cd $RPMDIR
mkdir -p BUILD RPMS/`uname -i` SOURCES SPECS SRPMS

# create rpm macro file
cat <<EOF >> ~/.rpmmacros
%_signature gpg
%_gpg_name AVALabs <builds@avalabs.org>

%packager      RPM Builds <builds@avalabs.org>
%vendor        AVALabs
%_topdir       ${RPMDIR}

%__gpg_sign_cmd %{__gpg} \
    gpg --no-verbose --no-armor --batch --pinentry-mode loopback --passphrase-file=${GPASS} \
    %{?_gpg_digest_algo:--digest-algo %{_gpg_digest_algo}} \
    --no-secmem-warning \
    %{?_gpg_sign_cmd_extra_args:%{_gpg_sign_cmd_extra_args}} \
    -u "%{_gpg_name}" -sbo %{__signature_filename} %{__plaintext_filename}
EOF

# copy files into rpm build directories
cp /drone/src/build/ava $RPMDIR/SOURCES/
cp /drone/src/build/xputtest $RPMDIR/SOURCES/
cp /drone/src/deploy/rpm/ava.spec $RPMDIR/SPECS/

# install system build tools
yum -y install rpm-build rpm-sign

# define the options for $MODE we can run in
NIGHTLY="nightly"
TAGGED="tagged"

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
    MODE=$NIGHTLY
else
    # tagged build
    # split version components from tag
    MAJOR=${GIT_TAG:0:1}
    MINOR=${GIT_TAG:2:1}
    PATCH=${GIT_TAG:4:1}
    RPM_VER="${MAJOR}.${MINOR}"
    RPM_REL="${PATCH}"
    MODE=$TAGGED
fi

# modify spec to replace our template variables
cd $RPMDIR/SPECS/
sed -i "s/%%RPM_VER%%/$RPM_VER/g" ava.spec
sed -i "s/%%RPM_REL%%/$RPM_REL/g" ava.spec

# build RPM
rpmbuild -bb ava.spec

# sign the rpm build
echo "Signing RPM"
rpm --resign $RPMDIR/RPMS/x86_64/avalabs-gecko-*.`uname -i`.rpm

# output information on build rpm
echo "Dumping RPM package information"
rpm -qpi $RPMDIR/RPMS/x86_64/*.rpm

# install RPM and test the binaries are working
#yum -y localinstall $RPMDIR/RPMS/x86_64/avalabs-gecko-*.`uname -i`.rpm

# disable tests until exit codes are corrected in code
#ava --help
#xputtest --help

# copy built rpm to mounted store volume
mkdir /store/$MODE
cp $RPMDIR/RPMS/x86_64/*.rpm /store/$MODE/

# copy our files used for building the RPM on the host server
cp /drone/src/deploy/rpm/publish.sh /store/rpm-publish.sh
chmod 700 /store/rpm-publish.sh

