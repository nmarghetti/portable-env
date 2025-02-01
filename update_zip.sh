#! /bin/sh

SCRIPT_ROOT=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_ROOT" || exit 1

zip portable_env.zip -ru certificates ini.bat setup_user.ini setup_install.cmd settings
