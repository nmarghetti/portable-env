@echo off

set APPS_ROOT=%CD%
if "%COMMON_ENV_INSTALL_SETUP_INI%" == "" (
  set COMMON_ENV_INSTALL_SETUP_INI=setup.ini
)
REM Set the only few app to run, (eg. git shell), or leave empty for all
if "%COMMON_ENV_INSTALL_ONLY_APP%" == "" (
  set COMMON_ENV_INSTALL_ONLY_APP=
)
REM Set the only few extra app to run, (eg. upgrade_portable_env), or leave empty for all
if "%COMMON_ENV_INSTALL_ONLY_EXTRA_APP%" == "" (
  set COMMON_ENV_INSTALL_ONLY_EXTRA_APP=
)


set PORTABLE_ENV_PATH=

if exist setup_install.log (
  del setup_install.log
)

set CHECK_FOR_DOWNLOAD=1
if exist wget.exe (
  set DOWNLOAD="%CD%\wget.exe --progress=bar:force -O"
  set CHECK_FOR_DOWNLOAD=0
)
if %CHECK_FOR_DOWNLOAD%==1 (
  wget -h > nul 2>&1
  if not errorlevel 1 (
    set DOWNLOAD="wget --progress=bar:force -O"
  ) else (
    curl -h > nul 2>&1
    if not errorlevel 1 (
      set DOWNLOAD="curl --progress-bar -kLo"
    ) else (
      echo "Unable to find wget or curl, please download https://eternallybored.org/misc/wget/1.20.3/64/wget.exe and save it along setup_develop.cmd"
      pause
      exit 1
    )
  )
)

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

@REM Ensure profile is set
set result=
%assign% "ini.bat /s install /i profile setup_user.ini",result
if "%result%" EQU "" (
  echo You need to setup "[install] profile" in setup_user.ini
  pause
  exit 1
) else (
  if exist %result%.ini (
    set COMMON_ENV_INSTALL_SETUP_INI=%result%.ini
  ) else (
    set COMMON_ENV_INSTALL_SETUP_INI=settings\profiles\%result%.ini
  )
)
if not exist "%COMMON_ENV_INSTALL_SETUP_INI%" (
  echo The profile %result% is not found: neither %result%.ini nor settings\profiles\%result%.ini exist.
  pause
  exit 1
)
echo Using setup configuration file '%COMMON_ENV_INSTALL_SETUP_INI%'
copy /Y "%COMMON_ENV_INSTALL_SETUP_INI%" setup.ini > nul
set COMMON_ENV_INSTALL_SETUP_INI=setup.ini

@REM Retrieve common_env path if set
set result=
%assign% "ini.bat /s install /i common-env-apps-root setup_user.ini 2>nul",result
if not "%result%" EQU "" (
  set COMMON_ENV_INSTALL_APPS_ROOT=%result%
)

@REM Retrieve portable-env path if set
set result=
%assign% "ini.bat /s install /i portable-env-path setup_user.ini 2>nul",result
if not "%result%" EQU "" (
  set PORTABLE_ENV_PATH=%result%
)

@REM Ensure git url is set
set result=
%assign% "ini.bat /s git /i url setup_user.ini",result
if "%result%" EQU "" (
  echo You need to setup "[git] url" in setup_user.ini
  pause
  exit 1
) else (
  set git_url=%result%
)

@REM Set git user if not set
set result=
%assign% "ini.bat /s git /i user setup_user.ini",result
if "%result%" EQU "" (
  %assign% "ini.bat /s git /i user /v %USERNAME% setup_user.ini",result
)

@REM Ensure git email is set
set result=
%assign% "ini.bat /s git /i email setup_user.ini",result
if "%result%" EQU "" (
  echo You need to setup "[git] email" in setup_user.ini
  pause
  exit 1
)

@REM Update setup.ini
setlocal EnableDelayedExpansion
set sections=(install git)
set install_fields=app-only custom-app-only
set git_fields=user email
for %%S in %sections% do (
  if not "%%S" EQU "" (
    set section=%%S
    set fields=!%%S_fields!
    for %%F in (!fields!) do (
      set field=%%F
      set result=
      %assign% "ini.bat /s !section! /i !field! setup_user.ini 2>nul",result
      if not "!result!" EQU "" (
        %assign% "ini.bat /s !section! /i !field! /v !result! %COMMON_ENV_INSTALL_SETUP_INI%",result
        echo Updated [!section!] !field! = !result!
      )
    )
  )
)

if "%COMMON_ENV_INSTALL_APPS_ROOT%" == "" (
  @REM Download setup.cmd
  "%DOWNLOAD%" setup.cmd "https://raw.githubusercontent.com/nmarghetti/common_env/master/tools/setup.cmd"
  if errorlevel 1 (
    echo "Error: unable to download setup.cmd"
    pause
    exit 1
  )
) else (
  COPY %COMMON_ENV_INSTALL_APPS_ROOT%\Documents\dev\common_env\tools\setup.cmd .
)

set COMMON_ENV_INSTALL_NO_EXIT=1

@REM Ensure to have gitbash first
set BACKUP_COMMON_ENV_INSTALL_ONLY_APP=%COMMON_ENV_INSTALL_ONLY_APP%
set COMMON_ENV_INSTALL_ONLY_APP=gitbash shell git portableapps
if exist "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" (
  if exist "%APPS_ROOT%\home\.ssh\id_rsa.pub" (
    set COMMON_ENV_INSTALL_ONLY_APP=
  ) else (
    call setup.cmd
  )
) else (
  call setup.cmd
)
set COMMON_ENV_INSTALL_ONLY_APP=%BACKUP_COMMON_ENV_INSTALL_ONLY_APP%
if not exist "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" (
  echo Unable to find %APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe, exiting...
  pause
  exit 1
)
if not exist "%APPS_ROOT%\home\.ssh\id_rsa.pub" (
  echo Unable to find %APPS_ROOT%\home\.ssh\id_rsa.pub, exiting...
  pause
  exit 1
)

@REM Extract the domain from the git_url
@REM Examples of git_url:
@REM   - https://user:token@github.com/owner/common_env.git
@REM   - https://github.com/owner/common_env.git
@REM   - git@github.com:owner/common_env.git
@REM   - ssh://git@github.com:user/repo.git
if "%git_url:~0,8%"=="https://" (
  for /f "tokens=1-3 delims=/" %%a in ("%git_url%") do set temp_url=%%b
) else if "%git_url:~0,7%"=="http://" (
  for /f "tokens=1-3 delims=/" %%a in ("%git_url%") do set temp_url=%%b
) else if "%git_url:~0,6%"=="ssh://" (
  for /f "tokens=1-3 delims=/" %%a in ("%git_url%") do set temp_url=%%b
) else (
    set temp_url=%git_url%
)
for /f "tokens=2 delims=@" %%a in ("%temp_url%") do set domain=%%a
if "%domain%" == "" (
  set domain=%temp_url%
)
for /f "tokens=1 delims=:" %%a in ("%domain%") do set domain=%%a

@REM Ensure to have the domain as known host
findstr /B /C:"%domain%" "%APPS_ROOT%\PortableApps\home\.ssh\known_hosts" >nul 2>&1 || (
  "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" -c "cd ./home/.ssh && ssh-keyscan %domain% >> ./known_hosts" >> setup_install.log 2>&1
)

REM Generate ca-bundle.crt
"%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%APPS_ROOT%\settings\certificates\bundle.sh"
if errorlevel 1 (
  echo.
  echo Error with certificates, please fix the error above and run again.
  pause
  exit 1
)

if "%PORTABLE_ENV_PATH%" EQU "" (
  @REM Clone portable-env repo if not done yet
  if not exist "%APPS_ROOT%\Documents\dev\portable-env\setup_install.cmd" (
    "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" -c "git clone %git_url% '%APPS_ROOT%\Documents\dev\portable-env'"
    @REM Force to update the setup on first clone
    "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%APPS_ROOT%\Documents\dev\portable-env\update_setup.sh" --force
  ) else (
    "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" -c "cd '%APPS_ROOT%\Documents\dev\portable-env' && git remote set-url origin '%git_url%'"
    "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%APPS_ROOT%\Documents\dev\portable-env\update_setup.sh"
  )
) else (
  REM Set to 1 for not syncing setup_install.cmd, useful for development
  set SYNC_SETUP_EXCLUDE_SETUP_INSTALL=0
  "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%PORTABLE_ENV_PATH%\sync_setup.sh"
)

set COMMON_ENV_INSTALL_NO_EXIT=0
call setup.cmd
