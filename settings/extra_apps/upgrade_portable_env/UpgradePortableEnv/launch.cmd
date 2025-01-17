@echo off

cd ..\..
@REM Update files
set APPS_ROOT=%CD%
set PORTABLE_ENV_PATH=%APPS_ROOT%\Documents\dev\portable-env

::::: ---- defining the assign macro ---- ::::::::
setlocal DisableDelayedExpansion
(set LF=^
%=EMPTY=%
)
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

::set argv=Empty
set assign=for /L %%n in (1 1 2) do ( %\n%
   if %%n==2 (%\n%
      setlocal EnableDelayedExpansion%\n%
      for /F "tokens=1,2 delims=," %%A in ("!argv!") do (%\n%
         for /f "tokens=* delims=" %%# in ('%%~A') do endlocal^&set "%%~B=%%#" %\n%
      ) %\n%
   ) %\n%
) ^& set argv=,

::::: -------- ::::::::

@REM Retrieve portable-env path if set
set result=
%assign% "ini.bat /s install /i portable-env-path setup_user.ini 2>nul",result
if not "%result%" EQU "" (
  set PORTABLE_ENV_PATH=%result%
)


"%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%PORTABLE_ENV_PATH%\update_setup.sh"

cd "%APPS_ROOT%"
START /WAIT /I /B /D "%APPS_ROOT%" setup_install.cmd

exit 0
