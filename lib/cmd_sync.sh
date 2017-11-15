#!/bin/bash

BASE="$(dirname "$(readlink -f "$0")")"

[ -z "$INIT_MSG" ]         && source "$BASE/lib_msg.sh"
[ -z "$INIT_CONFIG" ]      && source "$BASE/lib_config.sh"
[ -z "$INIT_SYNC" ]        && source "$BASE/lib_sync.sh"
[ -z "$INIT_HOOK_HELPER" ] && source "$BASE/hook_helper.sh"
[ -z "$INIT_HOOK" ]        && source "$BASE/lib_hook.sh"

DRY_RUN=true
source "$BASE/lib_dry_run.sh"

uninstall_module() {
  local installedModulePath="$1"
  local linkLog="$(config::link_log_path "$installedModulePath")"
  cat "$linkLog" | while read linkTarget; do
    unlink "$HOME/$linkTarget"
    # rmdir still might fail when it don't have permission to remove the
    # directory, so ignore the error here.
    rmdir --ignore-fail-on-non-empty --parents "$(dirname "$HOME/$linkTarget")" 2> /dev/null || echo -n
  done
  rm -f "$linkLog"
}

uninstall_modules() {
  sync::list_the_modules_need_remove | while read installedModulePath; do
    uninstall_module "$installedModulePath"
    rm -fr "$installedModulePath"
  done
}

install_module() {
  local modulePath="$1"
  local absModulePath="$(config::get_module_path "$modulePath")"
  (
    export HCM_MODULE_LINK_LOG="$(config::get_module_link_log_path "$modulePath")"
    hook::install "$absModulePath"
    # sort the file for deterministic result
    if [ -r "$HCM_MODULE_LINK_LOG" ]; then
      LC_ALL=C sort "$HCM_MODULE_LINK_LOG" -o "$HCM_MODULE_LINK_LOG"
    fi
    backup_installed_module "$modulePath"
  )
}

install_modules() {
  config::get_modules | while read modulePath; do
    local skipUninstall=true
    local skipInstall=true
    case "$(sync::check_module_status "$modulePath")" in
      $STATUS_UP_TO_DATE)
        # Skip the already installed module that has no update.
        continue
        ;;
      $STATUS_UPDATED|*)
        skipUninstall=false
        skipInstall=false
        ;;
      $STATUS_NEW)
        skipUninstall=true
        skipInstall=false
        ;;
    esac

    $skipUninstall || uninstall_module "$(config::get_backup_module_path "$modulePath")"
    $skipInstall || install_module "$modulePath"
  done
}

# Make a copy of the installed module, this is needed for uninstall. So even the
# user deleted and orignal copy, hcm still knows how to uninstall it.
backup_installed_module() {
  local absModulePath="$(config::get_module_path "$modulePath")"
  local backupModulePath="$(config::get_backup_module_path "$modulePath")"

  mkdir -p "$(dirname "$backupModulePath")"
  if which rsync &> /dev/null; then
    rsync -r --links "$absModulePath/" "$backupModulePath"
  else
    rm -fr "$backupModulePath"
    cp -d -r "$absModulePath" "$backupModulePath"
  fi
}

main() {
  config::verify
  uninstall_modules
  install_modules
}

[[ "$DEBUG" != "" ]] && set -x
set -e
main "$@"
