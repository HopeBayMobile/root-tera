#!/bin/bash

if [ "$1" == "install" ] ; then
    TMP=`mktemp`

    adb shell su --mount-master -c id &&
    adb install HopebayHCFSmgmt.apk 2> $TMP &&
    adb push hcfs hcfsapid hcfsconf HCFSvol hcfs.conf libcurl.so libfuse.so libjansson.so libzip.so tera /sdcard/ &&
    adb shell su --mount-master -c mv /sdcard/tera /dev/ &&
    adb shell su --mount-master -c chmod 777 /dev/tera &&
    adb shell su --mount-master -c /dev/tera install

    RET=$?

    adb shell su --mount-master -c rm -f /sdcard/hcfs /sdcard/hcfsapid /sdcard/hcfsconf /sdcard/HCFSvol /sdcard/hcfs.conf /sdcard/libcurl.so /sdcard/libfuse.so /sdcard/libjansson.so /sdcard/libzip.so /sdcard/tera /dev/tera

    if [ $RET -ne 0 ] ; then
        cat $TMP | grep -qw INSTALL_FAILED_ALREADY_EXISTS
        if [ $? -eq 0 ] ; then
            echo
            echo Tera INSTALL_FAILED_ALREADY_EXISTS
            echo
        else
            echo
            echo Tera Install Fail
            echo
        fi
    fi

    rm -f $TMP

    exit 0
fi

if [ "$1" == "uninstall" ] ; then
    adb shell su --mount-master -c id &&
    adb uninstall com.hopebaytech.hcfsmgmt 2> /dev/null &&
    adb push tera /sdcard/ &&
    adb shell su --mount-master -c mv /sdcard/tera /dev/ &&
    adb shell su --mount-master -c chmod 777 /dev/tera &&
    adb shell su --mount-master -c /dev/tera uninstall

    adb shell su --mount-master -c rm -f /dev/tera

    exit 0
fi

echo $0 install
echo $0 uninstall
exit 1
