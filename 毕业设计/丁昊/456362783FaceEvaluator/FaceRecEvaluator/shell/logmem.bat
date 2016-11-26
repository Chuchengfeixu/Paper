@echo off
echo Logging memory consumed by Matlab to %1 until %2 is present
rem echo %1
rem echo %2

:begin
if exist %2 goto end

del "shell\memsnap.log"
"shell/memsnap.exe" "shell/memsnap.log"
"shell/cat.exe" "shell/memsnap.log" | "shell/grep.exe" -i matlab | "shell/sed.exe" "s/MATLAB.exe//g" | "shell/sed.exe" "s/[ ]* / /g" | "shell/cut.exe" -f2 -d" " >> %1
"shell/sleep.exe" -m 40
goto begin

:end
del %2
echo end
exit

:veryend