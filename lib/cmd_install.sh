#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

[ -z "$INIT_MSG" ]         && source "$BASE/lib_msg.sh"
[ -z "$INIT_CONFIG" ]      && source "$BASE/lib_config.sh"
[ -z "$INIT_HOOK_HELPER" ] && source "$BASE/hook_helper.sh"
[ -z "$INIT_HOOK" ]        && source "$BASE/lib_hook.sh"

DRY_RUN=true

install::remove_installed_module() {
  local installedModulePath="$1"
  rm -fr "$installedModulePath"
}

install::uninstall_module() {
  local installedModulePath="$1"
  local linkLog="$(config::link_log_path "$installedModulePath")"
  cat "$linkLog" | while read linkTarget; do
    unlink "$HOME/$linkTarget"
    # rmdir still might fail when it don't have permission to remove the
    # directory, so ignore the error here.
    rmdir --ignore-fail-on-non-empty --parents "$(dirname "$HOME/$linkTarget")" || echo -n
  done
  rm -f "$linkLog"
}

install::uninstall_modules() {
  # Get the list of installed modules which no longer mentioned in the main
  # config.
  {
    config::get_modules | while read modulePath; do
      local installedModulePath="$(config::get_backup_module_path "$modulePath")"
      echo "$installedModulePath"
      echo "$installedModulePath"
    done
    find "$HCM_INSTALLED_MODULES_ROOT" -maxdepth 1 -mindepth 1 -type d
  } | sort | uniq -u | while read installedModulePath; do
    install::uninstall_module "$installedModulePath"
    install::remove_installed_module "$installedModulePath"
  done
}

install::install_module() {
  local modulePath="$1"
  local absModulePath="$(config::get_module_path "$modulePath")"
  hook::install "$absModulePath"
}

install::install_modules() {
  config::get_modules | while read modulePath; do
    # Skip the already installed module that has no update.
    config::if_module_has_no_update "$modulePath" && continue
    (
      export HCM_MODULE_LINK_LOG="$(config::get_module_link_log_path "$modulePath")"
      install::install_module "$modulePath"
      install::backup_installed_module "$modulePath"
    )
  done
}

# Make a copy of the installed module, this is needed for uninstall. So even the
# user deleted and orignal copy, hcm still knows how to uninstall it.
install::backup_installed_module() {
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
  local POSITIONAL=()
  while (( $# > 0 )); do
    case "$1" in
      -n|--dry-run)
        shift
        DRY_RUN=true
        ;;
      -f|--no-dry-run)
        shift
        DRY_RUN=false
        ;;
      *)
        POSITIONAL+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  config::verify
  install::uninstall_modules
  install::install_modules
}

[[ "$DEBUG" != "" ]] && set -x
set -e
main "$@"
