#!/bin/bash
##
## Copyright (c) 2021 HopeBayTech.
##
## This file is part of Tera.
## See https://github.com/HopeBayMobile for further info.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

ARG1=$1

if [ "$ARG1" == "install" ] ; then
    TMP=`mktemp`

    echo $0

    adb version &&
    adb shell su -c id &&
    adb install files/HopebayHCFSmgmt.apk &> $TMP &&
    adb push files/hcfs /sdcard/ &&
    adb push files/hcfsapid /sdcard/ &&
    adb push files/hcfsconf /sdcard/ &&
    adb push files/HCFSvol /sdcard/ &&
    adb push files/libcurl.so /sdcard/ &&
    adb push files/libfuse.so /sdcard/ &&
    adb push files/libjansson.so /sdcard/ &&
    adb push files/libzip.so /sdcard/ &&
    adb push hcfs.conf /sdcard/ &&
    adb push tera /sdcard/

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

    adb shell su -c "'cp -f /sdcard/tera /dev/ &> /dev/null'"
    adb shell su -c "'cp -f /storage/emulated/0/tera /dev/ &> /dev/null'"
    adb shell "rm /sdcard/tera"
    adb shell su -c "'chmod 777 /dev/tera'"
    adb shell su -c "'/dev/tera $ARG1 $0'"

    rm -f $TMP

    exit 0
fi

if [ "$ARG1" == "uninstall" ] ; then
    adb shell su -c id
    adb uninstall com.hopebaytech.hcfsmgmt 2> /dev/null
    adb push tera /sdcard/

    adb shell su -c "'cp -f /sdcard/tera /dev/ &> /dev/null'"
    adb shell su -c "'cp -f /storage/emulated/0/tera /dev/ &> /dev/null'"
    adb shell "rm /sdcard/tera"
    adb shell su -c "'chmod 777 /dev/tera'"
    adb shell su -c "'/dev/tera $ARG1'"

    exit 0
fi

echo $0 install
echo $0 uninstall
exit 1
