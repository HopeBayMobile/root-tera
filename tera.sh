#!/system/bin/sh

echo
echo Tera Version: 0.3.0
echo

EXE=$0
EXE_NAME=`basename $EXE`

function uninstall()
{
    if [ "$SD_DEFAULT" != "" ] ; then
        umount $SD_DEFAULT/MY-TERA 2> /dev/null
    fi
    if [ "$SD_READ" != "" ] ; then
        umount $SD_READ/MY-TERA 2> /dev/null
    fi
    if [ "$SD_WRITE" != "" ] ; then
        umount $SD_WRITE/MY-TERA 2> /dev/null
    fi

    umount $SDCARD/MY-TERA/ 2> /dev/null

    killall hcfsapid 2> /dev/null
    sleep 0.1
    killall -9 hcfsapid 2> /dev/null
    killall hcfs 2> /dev/null
    sleep 0.1
    killall -9 hcfs 2> /dev/null

    sleep 0.1

    rm -rf /data/hcfs /data/hcfs.conf /data/hcfs_android_log /data/hcfsapid.log /dev/shm

    mount -o rw,remount /system
    rm -rf /system/hcfs/
    mount -o ro,remount /system

    mount -o rw,remount /
    umount /tmp/ 2> /dev/null
    rmdir /tmp 2> /dev/null
    rm -rf $SDCARD/MY-TERA
    mount -o ro,remount /
}

function install()
{
    mount -o rw,remount /system
    mkdir -p /system/hcfs
    chmod 0755 /system/hcfs
    mv $EXE /sdcard/hcfs /sdcard/hcfsapid /sdcard/hcfsconf /sdcard/hcfs.conf /sdcard/HCFSvol /sdcard/libcurl.so /sdcard/libfuse.so /sdcard/libjansson.so /sdcard/libzip.so /system/hcfs/
    chown root:root /system/hcfs/hcfs.conf /system/hcfs/libcurl.so /system/hcfs/libfuse.so /system/hcfs/libjansson.so /system/hcfs/libzip.so
    chmod 644 /system/hcfs/libcurl.so /system/hcfs/libfuse.so /system/hcfs/libjansson.so /system/hcfs/libzip.so
    chown root:system /system/hcfs/hcfs /system/hcfs/hcfsapid /system/hcfs/hcfsconf /system/hcfs/HCFSvol
    chmod 0755 /system/hcfs/hcfs /system/hcfs/hcfsapid /system/hcfs/hcfsconf /system/hcfs/HCFSvol
    chown root:root /system/hcfs/$EXE_NAME
    chmod 4755 /system/hcfs/$EXE_NAME
    mount -o ro,remount /system

    mkdir -p /data/hcfs /data/hcfs/metastorage /data/hcfs/blockstorage
}

export LD_LIBRARY_PATH=/system/hcfs
export PATH=$PATH:/system/hcfs

trap "" SIGHUP

SDCARD="/sdcard"
while [ 1 ] ; do
    LINK=`readlink $SDCARD`
    if [ "$LINK" == "" ] ; then
        break
    fi
    SDCARD=$LINK
done

echo "SDCARD=$SDCARD"

SD_DEFAULT=""
SD_READ=""
SD_WRITE=""
echo "$SDCARD" | grep -q "^\/storage\/"
if [ $? -eq 0 ] ; then
    V=`echo $SDCARD | sed "s/^\/storage\//\/mnt\/runtime\/default\//g"`
    if [ -e $V ] ; then
        echo $V
        SD_DEFAULT=$V
    fi
    V=`echo $SDCARD | sed "s/^\/storage\//\/mnt\/runtime\/read\//g"`
    if [ -e $V ] ; then
        echo $V
        SD_READ=$V
    fi
    V=`echo $SDCARD | sed "s/^\/storage\//\/mnt\/runtime\/write\//g"`
    if [ -e $V ] ; then
        echo $V
        SD_WRITE=$V
    fi
fi

if [ "$1" == "uninstall" ] ; then
    rm $EXE
    uninstall
    sync

    echo
    echo Tera Uninstall OK
    echo

    exit
fi

if [ "$1" == "install" ] ; then
    if [ -e /system/hcfs -o -e /data/hcfs ] ; then
        rm $EXE

        echo
        echo Tera Already Install
        echo
        exit 1
    fi

    install

    rm -f $EXE

    echo
    echo Tera Install OK
    echo
fi

killall -0 hcfs 2> /dev/null
if [ $? -eq 0 ] ; then
    echo
    echo Tera Already Run
    echo

    exit 1
fi

mount -o rw,remount /
mkdir -p /tmp
chmod 0700 /tmp
mount -t tmpfs -o mode=0755,gid=1000 tmpfs /tmp
mkdir -p $SDCARD/MY-TERA
chmod 0777 $SDCARD/MY-TERA
mount -o ro,remount /

rm -rf /dev/shm
mkdir -p /dev/shm
chown root:system /dev/shm
chmod 0770 /dev/shm

hcfsconf enc /system/hcfs/hcfs.conf /data/hcfs.conf
while [ ! -e /data/hcfs.conf ]; do sleep 0.1; done

#MEDIA_RW_ID=`id media_rw | sed "s/^uid=\([0-9]*\).*/\1/g"`
hcfs -o big_writes,writeback_cache,rw,nosuid,nodev,noexec,noatime,default_permissions,allow_other &
while [ ! -e /dev/shm/hcfs_reporter ]; do sleep 0.1; done

HCFSvol create hcfs_data internal

HCFSvol mount hcfs_data $SDCARD/MY-TERA
chown root:sdcard_rw $SDCARD/MY-TERA
chmod 777 $SDCARD/MY-TERA

if [ "$SD_DEFAULT" != "" ] ; then
    mount | grep -q $SD_DEFAULT
    if [ $? -ne 0 ] ; then
        mount --bind $SDCARD/MY-TERA $SD_DEFAULT/MY-TERA
    fi
fi
if [ "$SD_READ" != "" ] ; then
    mount | grep -q $SD_READ
    if [ $? -ne 0 ] ; then
        mount --bind $SDCARD/MY-TERA $SD_READ/MY-TERA
    fi
fi
if [ "$SD_WRITE" != "" ] ; then
    mount | grep -q $SD_WRITE
    if [ $? -ne 0 ] ; then
        mount --bind $SDCARD/MY-TERA $SD_WRITE/MY-TERA
    fi
fi

HCFSvol create hcfs_external multiexternal

rm -f /data/data/com.hopebaytech.hcfsmgmt/hcfsapid_sock
hcfsapid &
while [ ! -e /data/data/com.hopebaytech.hcfsmgmt/hcfsapid_sock ]; do sleep 0.1; done

chown `ls -ld /data/data/com.hopebaytech.hcfsmgmt | tr -s " " | cut -d " " -f3,4 | tr " " ":"` /data/data/com.hopebaytech.hcfsmgmt/hcfsapid_sock

sync

if [ "$1" == "install" ] ; then
    #am start -n com.hopebaytech.hcfsmgmt/.main.MainActivity
    am start -n com.android.settings/.applications.InstalledAppDetails -d package:com.hopebaytech.hcfsmgmt
fi

echo
echo Tera Run OK
echo
