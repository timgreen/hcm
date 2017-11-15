INIT_SYNC=true

[ -z "$INIT_CONFIG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh

sync::if_no_update_for_module() {
  local modulePath="$1"
  local backupModulePath="$(config::get_backup_module_path "$modulePath")"
  local absModulePath="$(config::get_module_path "$modulePath")"
  diff -r --no-dereference "$absModulePath" "$backupModulePath" &> /dev/null
}
