#!/bin/bash
#
# script used for publishing the built DEB and updating the APT repository

# source of built DEB file/s on host server
DEB_STABLE="/home/repo/tagged/*.deb"
DEB_UNSTABLE="/home/repo/nightly/*.deb"

REPREPRO="/home/repo/reprepro-ex.sh"
REPO_BASE=/home/repo/apt
OS_LIST=(
    "xenial/stable"
    "xenial/unstable"
    "bionic/stable"
    "bionic/unstable"
    "focal/stable"
    "focal/unstable"
)


# update repo with new DEB for all distributions and versions
for OS in ${OS_LIST[@]}
do
    echo "Building repo for: ${OS}"

    # check if stable/unstable repo
    DEB_SRC=$DEB_STABLE
    if [[ $OS == *"/unstable"* ]]; then
        DEB_SRC=$DEB_UNSTABLE
    fi

    # add DEB to repo
    $REPREPRO -b $REPO_BASE includedeb $OS $DEB_SRC
done


# clean up build files
#rm -f $DEB_STABLE
#rm -f $DEB_UNSTABLE
#rm -f /home/repo/deb-publish.sh
#rm -f /home/repo/reprepro-ex.sh
