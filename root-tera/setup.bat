::
:: Copyright (c) 2021 HopeBayTech.
::
:: This file is part of Tera.
:: See https://github.com/HopeBayMobile for further info.
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
::
@ECHO OFF
PATH=%PATH%;"%SYSTEMROOT%\System32"
:: example:
::     tera.bat install
::     tera.bat uninstall
::
set help=Plz input install or uninstall

set argCount=0
for %%x in (%*) do Set /A argCount+=1

set SetupFileName=%0

IF (%1)==() goto CONSOLE

IF %argCount% GTR 1 echo %help% & goto END

set UserInput=%1
IF (%1)==(install) goto install
IF (%1)==(uninstall) goto uninstall

echo %help% & goto END

:CONSOLE
set /p UserInput=Plz input install or uninstall:
IF (%UserInput%)==(install) goto install
IF (%UserInput%)==(uninstall) goto uninstall

echo %help% & goto END

:install
echo install
echo %SetupFileName%
adb version && ^
adb shell su -c id && ^
adb install files\HopebayHCFSmgmt.apk >> tmp.txt 2>&1 && ^
adb push files\hcfs /sdcard/ && ^
adb push files\hcfsapid /sdcard/ && ^
adb push files\hcfsconf /sdcard/ && ^
adb push files\HCFSvol /sdcard/ && ^
adb push files\libcurl.so /sdcard/ && ^
adb push files\libfuse.so /sdcard/ && ^
adb push files\libHCFS_api.so /sdcard/ && ^
adb push files\libjansson.so /sdcard/ && ^
adb push files\libzip.so /sdcard/ && ^
adb push hcfs.conf /sdcard/ && ^
adb push tera /sdcard/
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
adb shell su -c "'cp -f /sdcard/tera /dev/ &> /dev/null'"
adb shell su -c "'cp -f /storage/emulated/0/tera /dev/ &> /dev/null'"
adb shell "rm /sdcard/tera"
adb shell su -c "'chmod 777 /dev/tera'"
adb shell su -c "'/dev/tera %UserInput% %SetupFileName%'"

:END
IF EXIST tmp.txt del tmp.txt
echo Press any key to exit...
pause >nul
