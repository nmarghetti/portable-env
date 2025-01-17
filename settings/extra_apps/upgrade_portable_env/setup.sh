#! /usr/bin/env bash

function setup_upgrade_portable_env() {
  # Upgrade portable env
  rsync -vau "$custom_tool_folder/upgrade_portable_env/UpgradePortableEnv" "$APPS_ROOT/PortableApps/"

  return 0
}
