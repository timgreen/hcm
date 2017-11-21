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
  local installedModulePath="$1"
  (
    export HCM_INSTALLED_MODULE_PATH="$installedModulePath"
    dryrun::internal_action hook::run_hook "$installedModulePath" pre-uninstall
    local linkLog="$(config::link_log_path "$installedModulePath")"
    cat "$linkLog" | while read linkTarget; do
      dryrun::action unlink "$HOME/$linkTarget"
      # rmdir still might fail when it doesn't have permission to remove the
      # directory, so ignore the error here.
      dryrun::action rmdir --ignore-fail-on-non-empty --parents "$(dirname "$HOME/$linkTarget")" 2> /dev/null || echo -n
    done
    dryrun::internal_action rm -f "$linkLog"
    dryrun::internal_action hook::run_hook "$installedModulePath" post-uninstall
    dryrun::internal_action rm -fr "$installedModulePath"
  )
}

uninstall_modules() {
  sync::list_the_modules_need_remove | while read installedModulePath; do
    uninstall_module "$installedModulePath"
  done
}

install_module() {
  local absModulePath="$1"
  (
    export HCM_ABS_MODULE_PATH="$absModulePath"
    dryrun::internal_action hook::run_hook "$absModulePath" pre-install
    dryrun::internal_action hook::install "$absModulePath"
    dryrun::internal_action hook::run_hook "$absModulePath" post-install
    # sort the file for deterministic result
    local linkLog="$(config::get_module_link_log_path "$absModulePath")"
    if [ -r "$linkLog" ]; then
      dryrun::internal_action tools::sort "$linkLog" -o "$linkLog"
    fi
    dryrun::internal_action backup_installed_module "$absModulePath"
  )
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
        uninstall_module "$(config::get_backup_module_path "$absModulePath")"
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

# Make a copy of the installed module, this is needed for uninstall. So even the
# user deleted and orignal copy, hcm still knows how to uninstall it.
backup_installed_module() {
  local absModulePath="$1"
  local backupModulePath="$(config::get_backup_module_path "$absModulePath")"

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
