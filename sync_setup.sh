#! /usr/bin/env bash

exit_error() {
  echo "$*" >&2
  exit 1
}

cd "$APPS_ROOT" || exit_error "Unable to go in '$APPS_ROOT'"
APPS_ROOT="$(pwd)"

portable_env_path=$(grep -E '^portable-env-path' <"$APPS_ROOT"/setup_user.ini | cut -d'=' -f2- | awk '{ print $1 }')

# shellcheck disable=SC2153
if [ -n "$portable_env_path" ]; then
  PORTABLE_ENV_PATH="$portable_env_path"
elif [ -z "$PORTABLE_ENV_PATH" ]; then
  PORTABLE_ENV_PATH="$APPS_ROOT/Documents/dev/portable-env/"
fi
cd "$PORTABLE_ENV_PATH" || exit_error "Unable to go in '$PORTABLE_ENV_PATH'"

tmp_file=$(mktemp)
{
  extra_sync=setup_install.cmd
  [ "$SYNC_SETUP_EXCLUDE_SETUP_INSTALL" = '1' ] && extra_sync=
  rsync -va --delete settings ini.bat $extra_sync "$APPS_ROOT/"
  rsync -va certificates "$APPS_ROOT/"
} | tee "$tmp_file"
if grep -qE "certificates/.*\.crt" "$tmp_file"; then
  "$APPS_ROOT"/settings/certificates/bundle.sh
fi
rm -f "$tmp_file"

if [ -z "$portable_env_path" ]; then
  git tag -f "${USER:-$USERNAME}" &>/dev/null
  git push -f origin refs/tags/"${USER:-$USERNAME}" &>/dev/null
fi

cd "$APPS_ROOT/" || exit_error "Unable to go in '$APPS_ROOT'"
