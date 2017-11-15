INIT_CONFIG=true

[ -z "$INIT_MSG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_msg.sh

HAS_YQ=$(which yq 2> /dev/null)
HAS_DOCKER=$(which docker 2> /dev/null)

config::yq() {
  if [ -n "$HAS_YQ" ]; then
    yq "$@"
  elif [ -n "$HAS_DOCKER" ]; then
    docker run -i evns/yq "$@"
  else
    msg::error "yq not available"
    exit 1
  fi
}

config::get_shell() {
  local scriptShell="$(cat "$MAIN_CONFIG" | config::yq -r .shell)"
  case "$scriptShell" in
    bash|null|'')
      echo bash
      ;;
    *)
      echo "$scriptShell"
      ;;
  esac
}

config::get_modules() {
  cat "$MAIN_CONFIG" | config::yq -r '.modules[]?'
}

config::_ensure_string_array_for_field() {
  local configPath="$1"
  local fieldPath="$2"

  local fieldType="$(cat "$configPath" | config::yq -r "([$fieldPath]|map(type))[0]")"
  [[ "$fieldType" == "" ]] && return
  [[ "$fieldType" == "null" ]] && return

  if [[ "$fieldType" != "array" ]]; then
    msg::error "Field '$fieldPath' must be array.\nFound errors in $configPath"
    exit 1
  fi
  local invalidTypeIndex="$(cat "$configPath" | config::yq -r "$fieldPath|map(type)|.[]" | nl -v0 -nln | grep '\(array\|object\)$' | head -n 1 | cut -d' ' -f 1)"
  if [[ "$invalidTypeIndex" != "" ]]; then
    msg::error "All items under field '$fieldPath' must be string. Found issue with index: $invalidTypeIndex"
    msg::error "In file: $configPath"
    cat "$configPath" | config::yq -y "$fieldPath[$invalidTypeIndex]"
    exit 1
  fi
}

config::_verify_main() {
  config::_ensure_string_array_for_field "$MAIN_CONFIG" ".modules"
}

config::_verify_module() {
  local modulePath="$1"
  local absModulePath="$(config::get_module_path "$modulePath")"
  if [ -z "$absModulePath" ] || [ ! -d "$absModulePath" ]; then
    msg::error "Invalid module '$modulePath', directory not exist."
    exit 1
  fi
  local absModuleConfigPath="$absModulePath/$MODULE_CONFIG"
  if [ ! -r "$absModuleConfigPath" ]; then
    msg::error "Invalid module '$modulePath', cannot read module config $absModuleConfigPath."
    exit 1
  fi
  config::_ensure_string_array_for_field "$absModuleConfigPath" ".after"
}

config::verify() {
  [ -r "$MAIN_CONFIG" ] || {
    msg::error 'Cannot read main config "\$HOME/.hcm/config.yml".'
    exit 1
  }

  config::_verify_main
  config::get_modules | while read modulePath; do
    config::_verify_module "$modulePath"
  done
}

config::get_module_path() {
  local modulePath="$1"
  local mainConfigPath="$(readlink -f $MAIN_CONFIG)"

  (
    cd "$(dirname "$mainConfigPath")"
    readlink -e "$modulePath"
  )
}

# use md5 as backup name, so we have a flat structure under $HOME/.hcm/installed_modules/
config::_get_flatten_name() {
  local modulePath="$1"
  echo "$modulePath" | md5sum | cut -c 1-32
}

config::get_backup_module_path() {
  local modulePath="$1"
  local flattenName="$(config::_get_flatten_name "$modulePath")"
  echo "$HCM_INSTALLED_MODULES_ROOT/$flattenName"
}

config::get_module_link_log_path() {
  local modulePath="$1"
  config::link_log_path "$(config::get_backup_module_path "$modulePath")"
}

config::link_log_path() {
  local installedModulePath="$1"
  echo "$installedModulePath.link.log"
}
