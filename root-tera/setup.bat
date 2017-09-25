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
adb shell su -c id && ^
adb install files/HopebayHCFSmgmt.apk >> tmp.txt 2>&1 && ^
adb push files/hcfs files/hcfsapid files/hcfsconf files/HCFSvol /sdcard/ && ^
adb push files/libcurl.so files/libfuse.so files/libHCFS_api.so files/libjansson.so files/libzip.so hcfs.conf tera /sdcard/
set RET=%ERRORLEVEL%

findstr "INSTALL_FAILED_ALREADY_EXISTS" tmp.txt
IF %ERRORLEVEL% EQU 0 echo Tera INSTALL_FAILED_ALREADY_EXISTS & goto END

IF %RET% NEQ 0 echo Tera Install Fail & goto END

goto START_UP

:uninstall
echo uninstall
adb shell su -c id
adb uninstall com.hopebaytech.hcfsmgmt 2> nul
adb push tera /sdcard/

:START_UP
adb shell su -c "cp -f /sdcard/tera /dev/ &> /dev/null"
adb shell su -c "cp -f /storage/emulated/0/tera /dev/ &> /dev/null"
adb shell "rm /sdcard/tera"
adb shell su -c "chmod 777 /dev/tera"
adb shell su -c "/dev/tera %1"

:END
IF (%1)==(install) del tmp.txt
echo Press any key to exit...
pause >nul