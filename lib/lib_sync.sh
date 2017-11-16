INIT_SYNC=true

STATUS_NEW='new'
STATUS_UP_TO_DATE='up-to-date'
STATUS_UPDATED='updated'

[ -z "$INIT_CONFIG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh

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
  } | sort | uniq -u
}
