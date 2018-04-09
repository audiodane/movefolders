@echo off
echo.
echo Copyright (c) 2018 audiodane (https://audiodane.dandk.org)
echo NO warranty is provided, expressed, or implied.  USE AT YOUR OWN RISK.
echo.

setLocal EnableDelayedExpansion
if "%1"=="" goto usagehelp
set destfolder=%1

rem get rid of trailing slash (if exists) so we can add it ourselves
IF "!destfolder:~-1!"=="\" SET destfolder=!destfolder:~,-1!

rem get current foldername
for %%a in (.) do set currentfolder=%%~na
set destfolder=%destfolder%\%currentfolder%
set copiedfolder=%currentfolder%\copied

echo.
echo copy "%currentfolder%" to "%destfolder%" ?
set /p myanswer="y/n: "
if "%myanswer%"=="y" goto continue
if "%myanswer%"=="Y" goto continue
goto cancel

:continue
echo.
echo creating folder: "%destfolder%"
mkdir "%destfolder%"
IF %ERRORLEVEL% GTR 0 goto mkdirerror
echo creating folder: "%copiedfolder%"
mkdir "%copiedfolder%"
IF %ERRORLEVEL% GTR 0 goto mkdirerror

echo copying "%currentfolder%" to "%destfolder%" ...

rem loop through all folders that are NOT already junction-links and NOT hidden
rem FOR /F "delims= usebackq" %%G IN (`dir/ad-l-h/b`) do echo %%G
FOR /F "delims= usebackq" %%G IN (`dir/ad-l-h/b`) do call :process %%G
echo.
echo all done.
goto end

:process
echo ***************************
set src=%*
set dest=%destfolder%\%*
echo moving "%src%" to "%dest%" ...
rem /MIR : mirror source to dest (caution: removes files too!)
rem /xj  : ignore reparse points (junctions)
rem /NFL : No File List - don't log file names.
rem /NDL : No Directory List - don't log directory names.
rem /NJH : No Job Header.
rem /NJS : No Job Summary.
rem /NP  : No Progress - don't display percentage copied.
rem /NS  : No Size - don't log file sizes.
rem /NC  : No Class - don't log file classes.
robocopy "%src%" "%dest%" /mir /xj /NFL /NDL /NJH /NJS /nc /ns
IF %ERRORLEVEL% LSS 8 goto noerror
Echo error with robocopy
:noerror
move "%src%" "%copiedfolder%"
mklink /j "%src%" "%dest%"
exit /b

:usagehelp
echo.
echo usage: movefolders {c:\dest\folder}
echo will move folders from current path location to dest\folder and create junction point links to the new location
goto end

:mkdirerror
echo.
echo error creating folder.  exiting.
goto end

:cancel
echo okay, exiting.
goto end

:end