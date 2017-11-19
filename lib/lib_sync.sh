INIT_SYNC=true

STATUS_NEW='new'
STATUS_UP_TO_DATE='up-to-date'
STATUS_UPDATED='updated'

[ -z "$INIT_CONFIG" ]      && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh
[ -z "$INIT_PATH_CONSTS" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path_consts.sh
[ -z "$INIT_TOOLS" ]       && source "$(dirname "${BASH_SOURCE[0]}")"/lib_tools.sh
[ -z "$INIT_SHELL" ]       && source "$(dirname "${BASH_SOURCE[0]}")"/lib_shell.sh

sync::check_module_status() {
  local absModulePath="$1"
  local backupModulePath="$(config::get_backup_module_path "$absModulePath")"
  if [ ! -d "$backupModulePath" ]; then
    echo "$STATUS_NEW"
  elif diff -r --no-dereference "$absModulePath" "$backupModulePath" &> /dev/null; then
    echo "$STATUS_UP_TO_DATE"
  else
    echo "$STATUS_UPDATED"
  fi
}

# Get the list of installed modules which no longer mentioned in the main
# config.
sync::list_the_modules_need_remove() {
  {
    config::get_module_list | while read absModulePath; do
      local installedModulePath="$(config::get_backup_module_path "$absModulePath")"
      echo "$installedModulePath"
      echo "$installedModulePath"
    done
    find "$HCM_INSTALLED_MODULES_ROOT" -maxdepth 1 -mindepth 1 -type d 2> /dev/null
  } | tools::sort | uniq -u
}

# Returns true if the given module is ready to install.
sync::ready_to_install() {
  local absModulePath="$1"
  # Ensure all the modules listed in '.after' have been installed.
  config::get_module_after_list "$absModulePath" | while read absAfterModulePath; do
    if [[ "$(sync::check_module_status "$absModulePath")" != "$STATUS_UP_TO_DATE" ]]; then
      return 1
    fi
  done
  # Ensure all the cmd listed in '.requires' can be found.
  config::get_module_requires_list "$absModulePath" | while read requiredCmd; do
    sync::is_cmd_available "$requiredCmd" || return 1
  done
}

# Return true if then given cmd is available in the current shell environment.
sync::is_cmd_available() {
  local cmd="$1"
  (
    case "$(config::get_shell)" in
      bash)
        shell::run_in::bash "type -t '$cmd'" | grep '\(alias\|function\|builtin\|file\)'
        ;;
      zsh)
        shell::run_in::zsh "whence -w '$cmd'" | grep '\(alias\|function\|builtin\|command\)'
        ;;
      *)
        shell::run_in::fallback "which '$cmd'"
        ;;
    esac
  ) &> /dev/null
}
