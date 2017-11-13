
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

config::_verify_main() {
  local fieldType="$(cat "$MAIN_CONFIG" | config::yq -r '([.modules]|map(type))[0]')"
  [[ "$fieldType" == "" ]] && return
  [[ "$fieldType" == "null" ]] && return

  if [[ "$fieldType" != "array" ]]; then
    msg::error "'modules' must be array"
    exit 1
  fi
  local invalidTypeIndex="$(cat "$MAIN_CONFIG" | config::yq -r '.modules|map(type)|.[]' | nl -v0 -nln | grep '\(array\|object\)$' | head -n 1 | cut -d' ' -f 1)"
  if [[ "$invalidTypeIndex" != "" ]]; then
    msg::error "All items under modules must be path. Found issue with index: $invalidTypeIndex"
    cat "$MAIN_CONFIG" | config::yq -y ".modules[$invalidTypeIndex]"
    exit 1
  fi
}

config::_verify_module() {
  local modulePath="$1"
  local absModulePath="$(config::get_module_path "$modulePath")"
  if [ ! -r "$absModulePath/$MODULE_CONFIG" ]; then
    msg::error "Invalid module '$modulePath', cannot read module config $MODULE_CONFIG."
    exit 1
  fi
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
