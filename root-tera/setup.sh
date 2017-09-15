#!/bin/bash

ARG1=$1

if [ "$ARG1" == "install" ] ; then
    TMP1=`mktemp`
    TMP2=`mktemp`

    adb shell su --mount-master -c id > $TMP1 &&
    adb install HopebayHCFSmgmt.apk &> $TMP2 &&
    adb push hcfs hcfsapid hcfsconf HCFSvol hcfs.conf libcurl.so libfuse.so libHCFS_api.so libjansson.so libzip.so tera _setup.sh /sdcard/

    RET=$?

    cat $TMP2 | grep -qw "INSTALL_FAILED_ALREADY_EXISTS"
    if [ $? -eq 0 ] ; then
        echo
        echo Tera INSTALL_FAILED_ALREADY_EXISTS
        echo

        rm -f $TMP1 $TMP2

        exit 1
    fi

    if [ $RET -ne 0 ] ; then
        echo
        echo Tera Install Fail
        echo

        rm -f $TMP1 $TMP2

        exit 1
    fi

    OPTION=""
    grep -q "uid=0(root)" $TMP1
    if [ $? -eq 0 ] ; then
        OPTION="--mount-master"
    fi

    adb shell su $OPTION -c "cp /sdcard/_setup.sh /dev/"
    adb shell su $OPTION -c "rm /sdcard/_setup.sh"
    adb shell su $OPTION -c "chmod 777 /dev/_setup.sh"
    adb shell su $OPTION -c "/dev/_setup.sh $ARG1"

    rm -f $TMP1 $TMP2

    exit 0
fi

if [ "$ARG1" == "uninstall" ] ; then
    TMP1=`mktemp`

    adb shell su --mount-master -c id > $TMP1 &&
    adb uninstall com.hopebaytech.hcfsmgmt 2> /dev/null &&
    adb push tera _setup.sh /sdcard/

    OPTION=""
    grep -q "uid=0(root)" $TMP1
    if [ $? -eq 0 ] ; then
        OPTION="--mount-master"
    fi

    adb shell su $OPTION -c "cp /sdcard/_setup.sh /dev/"
    adb shell su $OPTION -c "rm /sdcard/_setup.sh"
    adb shell su $OPTION -c "chmod 777 /dev/_setup.sh"
    adb shell su $OPTION -c "/dev/_setup.sh $ARG1"

    rm -f $TMP1

    exit 0
fi

echo $0 install
echo $0 uninstall
exit 1
