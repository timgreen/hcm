#!/bin/bash

BASE="$(dirname "$(readlink -f "$0")")"

# Options
DRY_RUN=true

[ -z "$INIT_CONFIG" ]      && source "$BASE/lib_config.sh"
[ -z "$INIT_DRY_RUN" ]     && source "$BASE/lib_dry_run.sh"
[ -z "$INIT_HOOK" ]        && source "$BASE/lib_hook.sh"
[ -z "$INIT_HOOK_HELPER" ] && source "$BASE/hook_helper.sh"
[ -z "$INIT_MSG" ]         && source "$BASE/lib_msg.sh"
[ -z "$INIT_SYNC" ]        && source "$BASE/lib_sync.sh"
[ -z "$INIT_TOOLS" ]       && source "$BASE/lib_tools.sh"

uninstall_module() {
  local moduleTrackBase="$1"
  local moduleBackupPath="$(config::backup_path_for "$moduleTrackBase")"
  msg::highlight "Uninstall $(basename $moduleTrackBase)"
  (
    export HCM_MODULE_BACKUP_PATH="$moduleBackupPath"
    dryrun::internal_action hook::run_hook "$moduleBackupPath" pre-uninstall
    sync::uninstall "$moduleTrackBase"
    dryrun::internal_action hook::run_hook "$moduleBackupPath" post-uninstall
    dryrun::internal_action sync::cleanup_after_uninstall "$moduleTrackBase"
  )
}

uninstall_modules() {
  sync::list_the_modules_need_remove | while read moduleTrackBase; do
    uninstall_module "$moduleTrackBase"
  done
}

install_module() {
  local absModulePath="$1"
  msg::highlight "Install $(basename $absModulePath)"
  (
    # try to install
    export HCM_ABS_MODULE_PATH="$absModulePath"
    dryrun::internal_action sync::prepare_before_install "$absModulePath"
    dryrun::internal_action hook::run_hook "$absModulePath" pre-install  || recover_error "$absModulePath" pre-install $?
    sync::install "$absModulePath"                                       || recover_error "$absModulePath" install $?
    dryrun::internal_action hook::run_hook "$absModulePath" post-install || recover_error "$absModulePath" post-install $?
  )
}

recover_error() {
  local absModulePath="$1"
  local lastStage="$2"
  local exitCode=$3
  local moduleTrackBase="$(config::to_module_track_base "$absModulePath")"
  local moduleBackupPath="$(config::backup_path_for "$moduleTrackBase")"
  (
    # try to revert the failed install
    export HCM_MODULE_BACKUP_PATH="$moduleBackupPath"
    if [[ "$lastStage" == "post-install" ]]; then
      dryrun::internal_action hook::run_hook "$moduleBackupPath" pre-uninstall
    fi
    if [[ "$lastStage" == "post-install" ]] || [[ "$lastStage" == "install" ]]; then
      sync::uninstall "$moduleTrackBase"
    fi
    if [[ "$lastStage" == "post-install" ]] || [[ "$lastStage" == "install" ]] || [[ "$lastStage" == "pre-install" ]]; then
      dryrun::internal_action hook::run_hook "$moduleBackupPath" post-uninstall
    fi
    dryrun::internal_action sync::cleanup_after_uninstall "$moduleTrackBase"
  )
  exit $exitCode
}

install_modules() {
  local pendingAbsModulePaths=()
  # First, go through the module list.
  #   - ignore the up-to-date modules.
  #   - uninstall the updated modules and add them to pending list
  #   - add new modules to pending list.
  local absModulePath
  while read absModulePath; do
    # NOTE: change to `output | while read x; do ... done` style could fix the
    # empty line input issue. But the while statement after pipe will be in a
    # new sub shell, the changes to $pendingAbsModulePaths won't visible
    # outside.
    [ -z "$absModulePath" ] && continue
    case "$(sync::check_module_status "$absModulePath")" in
      $STATUS_UP_TO_DATE)
        # Skip the already installed module that has no update.
        continue
        ;;
      $STATUS_NEW)
        pendingAbsModulePaths+=("$absModulePath")
        ;;
      $STATUS_UPDATED|*)
        uninstall_module "$(config::to_module_track_base "$absModulePath")"
        pendingAbsModulePaths+=("$absModulePath")
        ;;
    esac
  done <<< "$(config::get_module_list)"

  # Install pending modules.
  # Only install the first module with no unresolved dependencies in each
  # interation.
  while (( ${#pendingAbsModulePaths[@]} > 0 )); do
    local installedOneModule=false
    for i in "${!pendingAbsModulePaths[@]}"; do
      local absModulePath="${pendingAbsModulePaths[$i]}"
      if sync::ready_to_install "$absModulePath"; then
        install_module "$absModulePath"
        unset -v "pendingAbsModulePaths[$i]"
        installedOneModule=true
        break
      fi
    done
    if ! $installedOneModule; then
      msg::error "Cannot resolve following modules:"
      printf '%s\n' "${pendingAbsModulePaths[@]}"
      exit 1
    fi
  done
}

main() {
  config::verify
  uninstall_modules
  install_modules
}

[[ "$DEBUG" != "" ]] && set -x
set -e
main "$@"
