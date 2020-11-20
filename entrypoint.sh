#!/bin/bash

set -euo pipefail

TM_LICHOST=${TM_LICHOST:-127.0.0.1}
TM_LICPORT=${TM_LICPORT:-57777}
TM_LICPASS=${TM_LICPASS:-docker}

# Setup TMFL
function setup_tmfl() {
    sudo mkdir -p /opt/solutionsoft/timemachine
    echo "$TM_LICHOST:$TM_LICPORT:$TM_LICPASS" > /tmp/licserverhost
    sudo mv -f /tmp/licserverhost /opt/solutionsoft/timemachine/licserverhost
    sudo chown root:root /opt/solutionsoft/timemachine/licserverhost
    sudo chmod 0555 /opt/solutionsoft/timemachine/licserverhost
}

# Populate /opt/ssstm directory
function populate() {
    WORKD=${1:-/opt/ssstm}
    DIST="/dist"

    sudo mkdir -p $WORKD && sudo rm -rf $WORKD/* && sudo chown `id -u`:`id -g` $WORKD && sudo chmod a+rx $WORKD

    # populate rhat lib structure
    mkdir -p $WORKD/lib $WORKD/lib64
    install -m 0555 $DIST/lib32/libssstm.so $WORKD/lib
    install -m 0555 $DIST/lib64/libssstm.so $WORKD/lib64

    # populate debian lib structure
    mkdir -p $WORKD/lib32 $WORKD/lib/x86_64-linux-gnu
    install -m 0555 $DIST/lib32/libssstm.so $WORKD/lib32
    install -m 0555 $DIST/lib64/libssstm.so $WORKD/lib/x86_64-linux-gnu

    # setup environment
    mkdir -p $WORKD/etc
    echo '/opt/ssstm/$LIB/libssstm.so' > $WORKD/etc/ld.so.preload

    # populate TM daemon
    mkdir -p $WORKD/sbin
    install -m 0555 $DIST/sbin/tmdaemon $WORKD/sbin

    # populare TM user client
    mkdir -p $WORKD/bin
    install -m 0555 $DIST/bin/tmuser $WORKD/bin

    # change ownership to root
    sudo chown -R root:root $WORKD

    # container is ready
    sudo touch /.tm_is_ready
}

# Sanitize the system
function sanitize() {
    # remove sudo privilege for user default
    sudo rm -f /etc/sudoers.d/99-default-user
}

[ -f /opt/solutionsoft/timemachine/licserverhost ] || setup_tmfl
[ -d /.tm_is_ready ] || populate "/opt/ssstm"
[ -f /etc/sudoers.d/99-default-user ] && sanitize

echo "Sidecar for kubernetes is ready!"

# If we have an interactive container
if [ "$#" -gt 0 ]; then
    eval "exec $@"
else 
    exec /opt/ssstm/sbin/tmdaemon
fi

# Will not reach here 
exit 0
