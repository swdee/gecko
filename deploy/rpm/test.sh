#!/bin/bash
#
# script installs gecko on OS from YUM repository for integration testing

# install repo
yum -y install dnf-utils
dnf config-manager --add-repo http://50.116.4.66:8080/yum/avalabs.repo

if [ "${GIT_TAG}" == "" ]; then
    # install nightly snapshot
    dnf config-manager --set-enabled avalabs-${OS}-unstable
else
    # tagged build
    dnf config-manager --set-enabled avalabs-${OS}
fi

# install and test
yum -y install avalabs-gecko
ava --help
xputtest --help