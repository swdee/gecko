#!/bin/bash
#
# script installs gecko on OS from APT repository for integration testing

apt-get update -y

# install needed utils
apt-get -y install wget lsb-release software-properties-common

# install APT repo GPG key
wget -qO - http://50.116.4.66:8080/yum/RPM-GPG-KEY | sudo apt-key add -

# Add APT repo
if [ "${GIT_TAG}" == "" ]; then
    # nightly snapshot
    add-apt-repository "deb http://50.116.4.66:8080/apt/ `lsb_release -cs`/unstable main"
else
    # tagged build
    add-apt-repository "deb http://50.116.4.66:8080/apt/ `lsb_release -cs`/stable main"
fi

# install gecko
apt-get -y install avalabs-gecko

# test
ava --help
xputtest --help