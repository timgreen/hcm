INIT_SYNC=true

[ -z "$INIT_CONFIG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh

sync::if_no_update_for_module() {
  local modulePath="$1"
  local backupModulePath="$(config::get_backup_module_path "$modulePath")"
  local absModulePath="$(config::get_module_path "$modulePath")"
  diff -r --no-dereference "$absModulePath" "$backupModulePath" &> /dev/null
}

# Get the list of installed modules which no longer mentioned in the main
# config.
sync::list_the_modules_need_remove() {
  {
    config::get_modules | while read modulePath; do
      local installedModulePath="$(config::get_backup_module_path "$modulePath")"
      echo "$installedModulePath"
      echo "$installedModulePath"
    done
    find "$HCM_INSTALLED_MODULES_ROOT" -maxdepth 1 -mindepth 1 -type d 2> /dev/null
  } | sort | uniq -u
}
