#!/bin/bash

ARG1=$1

if [ "$ARG1" == "install" ] ; then
    TMP=`mktemp`

    adb shell su -c id &&
    adb install HopebayHCFSmgmt.apk &> $TMP &&
    adb push hcfs hcfsapid hcfsconf HCFSvol hcfs.conf libcurl.so libfuse.so libHCFS_api.so libjansson.so libzip.so tera /sdcard/

    RET=$?

    cat $TMP | grep -qw "INSTALL_FAILED_ALREADY_EXISTS"
    if [ $? -eq 0 ] ; then
        echo
        echo Tera INSTALL_FAILED_ALREADY_EXISTS
        echo

        rm -f $TMP

        exit 1
    fi

    if [ $RET -ne 0 ] ; then
        echo
        echo Tera Install Fail
        echo

        rm -f $TMP

        exit 1
    fi

    adb shell su -c "cp /sdcard/tera /dev/"
    adb shell "rm /sdcard/tera"
    adb shell su -c "chmod 777 /dev/tera"
    adb shell su -c "/dev/tera $ARG1"

    rm -f $TMP

    exit 0
fi

if [ "$ARG1" == "uninstall" ] ; then
    adb shell su -c id &&
    adb uninstall com.hopebaytech.hcfsmgmt 2> /dev/null &&
    adb push tera /sdcard/

    adb shell su -c "cp /sdcard/tera /dev/"
    adb shell "rm /sdcard/tera"
    adb shell su -c "chmod 777 /dev/tera"
    adb shell su -c "/dev/tera $ARG1"

    exit 0
fi

echo $0 install
echo $0 uninstall
exit 1
