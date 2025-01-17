#! /bin/sh

exit_error() {
  echo "$*" >&2
  exit 1
}

cd "$APPS_ROOT/Documents/dev/portable-env" || exit_error "Unable to go in '$APPS_ROOT/Documents/dev/portable-env'"

COMMON_ENV_CHANGED=$1

current_commit=$(git log -1 --pretty=format:%H)
# shellcheck disable=SC1091
. "$APPS_ROOT/Documents/dev/common_env/tools/shell/source/check_update.sh"
check_repo_update "$APPS_ROOT/Documents/dev/portable-env"
[ "$COMMON_ENV_CHANGED" -eq 1 ] && "$APPS_ROOT/Documents/dev/common_env/scripts/setup.sh" shell
if [ ! "$current_commit" = "$(git log -1 --pretty=format:%H)" ]; then
  ./sync_setup.sh
  cd "$APPS_ROOT" || exit_error "Unable to go in '$APPS_ROOT'"
  START "setup_install.cmd"
fi
