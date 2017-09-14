#!/system/bin/sh

EXE=$0

if [ "$1" == "install" ] ; then
    id &&
    cp /sdcard/tera /dev/ &&
    rm /sdcard/tera &&
    chmod 777 /dev/tera &&
    /dev/tera install

    RET=$?

    rm -f /sdcard/hcfs /sdcard/hcfsapid /sdcard/hcfsconf /sdcard/HCFSvol /sdcard/hcfs.conf /sdcard/libcurl.so /sdcard/libfuse.so /sdcard/libHCFS_api.so /sdcard/libjansson.so /sdcard/libzip.so /sdcard/tera /dev/tera $EXE

    if [ $RET -ne 0 ] ; then
        echo
        echo Tera Install Fail
        echo
    fi

    exit 0
fi

if [ "$1" == "uninstall" ] ; then
    id &&
    cp /sdcard/tera /dev/ &&
    rm /sdcard/tera &&
    chmod 777 /dev/tera &&
    /dev/tera uninstall

    rm -f /dev/tera $EXE

    exit 0
fi

rm -f $EXE

exit 1
