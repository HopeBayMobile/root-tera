#!/bin/bash

adb push shc tera.sh /sdcard/
adb shell su -c mv /sdcard/shc /dev/
adb shell su -c chmod 777 /dev/shc
adb shell su -c /dev/shc -f /sdcard/tera.sh
adb pull /sdcard/tera.sh.x.c
adb shell su -c rm /dev/shc /sdcard/tera.sh /sdcard/tera.sh.x.c

INSERT_LINE_NUM=`grep -n "int main(" tera.sh.x.c | cut -d ":" -f1`
INSERT_LINE_NUM=$[$INSERT_LINE_NUM+1]
sed -i "$INSERT_LINE_NUM a setuid(0);setgid(0);" tera.sh.x.c

scp tera.sh.x.c 172.16.40.100:~/
rm tera.sh.x.c
ssh 172.16.40.100 /home/cih/android/gcc/bin/aarch64-linux-gnu-gcc -static tera.sh.x.c -o tera
scp 172.16.40.100:~/tera root-tera/
ssh 172.16.40.100 rm tera.sh.x.c tera
