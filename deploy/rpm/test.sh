#!/bin/bash
#
# script installs gecko on OS from YUM repository for integration testing


install_centos() {
    yum -y install yum-utils
    yum-config-manager --add-repo http://50.116.4.66:8080/yum/avalabs.repo

    if [ "${GIT_TAG}" == "" ]; then
        # install nightly snapshot
        yum-config-manager --enable avalabs-${OS}-unstable
    else
        # tagged build
        yum-config-manager --enable avalabs-${OS}
    fi

    yum -y install avalabs-gecko
}


install_fedora() {
    dnf -y install dnf-utils
    dnf config-manager --add-repo http://50.116.4.66:8080/yum/avalabs.repo

    if [ "${GIT_TAG}" == "" ]; then
        # install nightly snapshot
        dnf config-manager --set-enabled avalabs-${OS}-unstable
    else
        # tagged build
        dnf config-manager --set-enabled avalabs-${OS}
    fi

    dnf -y install avalabs-gecko
}


# install gecko
if [ "${OS}" == "centos" ]; then
    install_centos
else
    install_fedora
fi


#  test
ava --help
xputtest --help