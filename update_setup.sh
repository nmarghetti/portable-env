#! /bin/sh

exit_error() {
  echo "$*" >&2
  exit 1
}

portable_env_path=$(grep -E '^portable-env-path' <"$APPS_ROOT"/setup_user.ini | cut -d'=' -f2- | awk '{ print $1 }')

# shellcheck disable=SC2153
if [ -n "$portable_env_path" ]; then
  cd "$portable_env_path" || exit_error "Unable to go in '$portable_env_path'"
  ./sync_setup.sh
  exit 0
elif [ -z "$PORTABLE_ENV_PATH" ]; then
  PORTABLE_ENV_PATH="$APPS_ROOT/Documents/dev/portable-env/"
fi

cd "$PORTABLE_ENV_PATH" || exit_error "Unable to go in '$PORTABLE_ENV_PATH'"

current_commit=$(git log -1 --pretty=format:%H)
git fetch
if ! git rebase origin/master || [ "$1" = "--force" ] || [ ! "$current_commit" = "$(git log -1 --pretty=format:%H)" ]; then
  ./sync_setup.sh
fi
