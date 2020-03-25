#!/bin/bash
#
# script used for publishing the built RPM and updating the YUM
# repository metadata

# source of build RPM file/s on host server
RPM_STABLE="/home/repo/tagged/*.rpm"
RPM_UNSTABLE="/home/repo/nightly/*.rpm"

REPO_BASE=/home/repo/yum
OS_LIST=(
    "fedora/29"
    "fedora/30"
    "fedora/31"
    "fedora/32"

    "fedora-unstable/29"
    "fedora-unstable/30"
    "fedora-unstable/31"
    "fedora-unstable/32"

    "centos/7"
    "centos/8"

    "centos-unstable/7"
    "centos-unstable/8"
)
ARCH="x86_64"


# update repo with new RPM for all distributions and versions
for OS in ${OS_LIST[@]}
do
    echo "Building repo for: ${OS}"

    # check if stable/unstable repo
    RPM_SRC=$RPM_STABLE
    if [[ $OS == *"-unstable"* ]]; then
        RPM_SRC=$RPM_UNSTABLE
    fi

    # copy RPM into place
    cp $RPM_SRC $REPO_BASE/$OS/$ARCH/

    # sign RPM and update repo metadata
    cd $REPO_BASE/$OS/$ARCH && createrepo .
done


# clean up build files
rm -f $RPM_STABLE
rm -f $RPM_UNSTABLE
rm -f /home/repo/publish.sh