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
  local metadataFile="$(config::metadata_file_for "$moduleTrackBase")"
  msg::highlight "Uninstall $(config::metadata::get_path "$metadataFile")"
  (
    export HCM_MODULE_BACKUP_PATH="$moduleBackupPath"
    dryrun::internal_action hook::run_hook "$moduleBackupPath" pre-uninstall || :
    sync::uninstall "$moduleTrackBase"
    dryrun::internal_action hook::run_hook "$moduleBackupPath" post-uninstall || :
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
  msg::highlight "Install $absModulePath"
  (
    # try to install
    export HCM_ABS_MODULE_PATH="$absModulePath"
    dryrun::internal_action sync::prepare_before_install "$absModulePath"
    dryrun::internal_action hook::run_hook "$absModulePath" pre-install  || fallback_failed_install "$absModulePath" pre-install $?
    sync::install "$absModulePath"                                       || fallback_failed_install "$absModulePath" install $?
    dryrun::internal_action hook::run_hook "$absModulePath" post-install || fallback_failed_install "$absModulePath" post-install $?
    sync::verify_provided_cmds "$absModulePath"                          || fallback_failed_install "$absModulePath" verify-provides $?
  )
}

fallback_failed_install() {
  local absModulePath="$1"
  local lastStage="$2"
  local exitCode=$3
  local moduleTrackBase="$(config::to_module_track_base "$absModulePath")"
  local moduleBackupPath="$(config::backup_path_for "$moduleTrackBase")"

  msg::error "Can not install module $absModulePath"
  msg::info "failed on stage $lastStage with exit code $exitCode"
  msg::info "cleanup ..."

  (
    # try to revert the failed install
    export HCM_MODULE_BACKUP_PATH="$moduleBackupPath"
    case "$lastStage" in
      verify-provides)
        ;&
      post-install)
        dryrun::internal_action hook::run_hook "$moduleBackupPath" pre-uninstall || :
        ;&
      install)
        sync::uninstall "$moduleTrackBase"
        ;&
      pre-install)
        dryrun::internal_action hook::run_hook "$moduleBackupPath" post-uninstall || :
    esac
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
    case "$(sync::check_module_status "$absModulePath")" in
      $STATUS_UP_TO_DATE)
        # Skip the already installed module that has no update.
        msg::highlight "Up-to-date $absModulePath"
        continue
        ;;
      $STATUS_NEW)
        pendingAbsModulePaths+=("$absModulePath")
        ;;
      $STATUS_UPDATED|*)
        msg::highlight "Updated, uninstall first $absModulePath"
        uninstall_module "$(config::to_module_track_base "$absModulePath")"
        pendingAbsModulePaths+=("$absModulePath")
        ;;
    esac
  done < <(config::get_module_list)

  # Go through 'requires' list for each module, report any missing cmds.
  if (( ${#pendingAbsModulePaths[@]} > 0 )); then
    report_missing_requires "$(declare -p pendingAbsModulePaths)"
  fi

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

report_missing_requires() {
  # Get a copy of pendingAbsModulePaths
  eval "declare -a pendingAbsModulePaths="${1#*=}
  declare -A installedProvides
  declare -A installedModules
  while (( ${#pendingAbsModulePaths[@]} > 0 )); do
    local installedOneModule=false
    for i in "${!pendingAbsModulePaths[@]}"; do
      local absModulePath="${pendingAbsModulePaths[$i]}"
      if sync::ready_to_install_virtual "$absModulePath" installedModules installedProvides; then
        installedModules["$absModulePath"]=true
        while read providedCmd; do
          [ -z "$providedCmd" ] && continue
          installedProvides["$providedCmd"]=true
        done < <(config::get_module_provides_list "$absModulePath")
        unset -v "pendingAbsModulePaths[$i]"
        installedOneModule=true
        break
      fi
    done
    if ! $installedOneModule; then
      msg::error "Cannot install following modules:"
      for i in "${!pendingAbsModulePaths[@]}"; do
        local absModulePath="${pendingAbsModulePaths[$i]}"
        report_unmet_requirements "$absModulePath" installedModules installedProvides
      done

      exit 1
    fi
  done
}

# report unmet requirements for each module in follow format
#
# <module_name>
#   requires:
#     ✔ <cmd_a>
#     ✘ <cmd_b>
#   after:
#     ✔ <module_a>
#     ✘ <module_b>
report_unmet_requirements() {
  local absModulePath="$1"
  local -n virtualInstalledModules="$2"
  local -n virtualInstalledProvides="$3"

  msg::highlight "$absModulePath"
  local indent="    "

  msg::info "  afters:"
  while read absAfterModulePath; do
    [ -z "$absAfterModulePath" ] && continue
    if [ ${virtualInstalledModules["$absAfterModulePath"]+_} ] || [[ "$(sync::check_module_status "$absAfterModulePath")" == "$STATUS_UP_TO_DATE" ]]; then
      echo "${indent}✔ $absAfterModulePath"
    fi
  done < <(config::get_module_after_list "$absModulePath")
  while read absAfterModulePath; do
    [ -z "$absAfterModulePath" ] && continue
    [ ${virtualInstalledModules["$absAfterModulePath"]+_} ] && continue
    [[ "$(sync::check_module_status "$absAfterModulePath")" == "$STATUS_UP_TO_DATE" ]] && continue
    echo "${indent}✘ $absAfterModulePath"
  done < <(config::get_module_after_list "$absModulePath")

  msg::info "  requires:"
  while read requiredCmd; do
    [ -z "$requiredCmd" ] && continue
    if [ ${virtualInstalledProvides["$requiredCmd"]+_} ] || sync::is_cmd_available "$requiredCmd"; then
      echo "${indent}✔ $requiredCmd"
    fi
  done < <(config::get_module_requires_list "$absModulePath")
  while read requiredCmd; do
    [ -z "$requiredCmd" ] && continue
    if [ ${virtualInstalledProvides["$requiredCmd"]+_} ] || sync::is_cmd_available "$requiredCmd"; then
      continue
    fi
    echo "${indent}✘ $requiredCmd"
  done < <(config::get_module_requires_list "$absModulePath")
}

main() {
  msg::info "Loading config ..."
  config::load_and_cache
  msg::info "Took $SECONDS seconds"
  uninstall_modules
  install_modules
}

[[ "$DEBUG" != "" ]] && set -x
set -euf -o pipefail
main "$@"
