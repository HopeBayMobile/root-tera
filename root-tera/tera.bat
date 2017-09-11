@ECHO OFF
PATH=%PATH%;"%SYSTEMROOT%\System32"
:: example:
::     tera.bat install
::     tera.bat uninstall
::
set help=Plz input install or uninstall

IF (%1)==() echo %help% & goto END
IF (%1)==(install) goto install
IF (%1)==(uninstall) goto uninstall

:install
echo install
adb shell su --mount-master -c id && ^
adb install -r HopebayHCFSmgmt.apk && ^
adb push hcfs hcfsapid hcfsconf HCFSvol hcfs.conf libcurl.so libfuse.so libjansson.so libzip.so tera /sdcard/ && ^
adb shell su --mount-master -c mv /sdcard/tera /dev/ && ^
adb shell su --mount-master -c chmod 777 /dev/tera && ^
adb shell su --mount-master -c /dev/tera install && goto INSTALL_END

echo TERA BAT INSTALL SCRIPT FAIL

goto INSTALL_END

:uninstall
echo uninstall
adb shell su --mount-master -c id
adb uninstall com.hopebaytech.hcfsmgmt
adb push tera /sdcard/
adb shell su --mount-master -c mv /sdcard/tera /dev/
adb shell su --mount-master -c chmod 777 /dev/tera
adb shell su --mount-master -c /dev/tera uninstall

if NOT %ERRORLEVEL% == 0 echo TERA BAT UNINSTALL SCRIPT FAIL

adb shell su --mount-master -c rm -f /dev/tera

goto END


:INSTALL_END
adb shell su --mount-master -c rm -f /sdcard/hcfs /sdcard/hcfsapid /sdcard/hcfsconf /sdcard/HCFSvol /sdcard/hcfs.conf /sdcard/libcurl.so /sdcard/libfuse.so /sdcard/libjansson.so /sdcard/libzip.so /sdcard/tera /dev/tera

:END
echo Press any key to exit...
pause >nul