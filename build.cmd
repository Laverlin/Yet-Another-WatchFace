SET CPath=%CIQ_SDK_Path%

rem c:\Projects\CIQSDK\connectiq-sdk-win-3.1.7-2020-01-23-a3869d977\bin\
SET AppName=YAWatchFace
SET Key=c:\#Sync\Projects\Garmin-Keys\YAWatchFace.key

SET Device=%1
IF NOT DEFINED Device (SET Device=fenix6xpro)

java -cp %CPath%\monkeybrains.jar; com.garmin.monkeybrains.Monkeybrains -o bin\%AppName%.prg -d %Device% -f .\monkey.jungle --warn --debug -y %Key% || GOTO :EOF

start %CPath%\simulator.exe 

java -classpath %CPath%\monkeybrains.jar com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux -f .\bin\%AppName%.prg -d %Device% -s %CPath%\shell.exe

rem %CPath%\monkeydo .\bin\%AppName%.prg %Device%