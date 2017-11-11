
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
  scriptShell="$(cat "$MAIN_CONFIG" | config::yq -r .shell)"
  if [[ "$scriptShell" == "" ]]; then
    echo bash
  else
    echo "$scriptShell"
  fi
}

config::get_modules() {
  fieldType="$(cat "$MAIN_CONFIG" | config::yq -r '([.modules]|map(type))[0]')"
  [[ "$fieldType" == "" ]] && return
  [[ "$fieldType" == "null" ]] && return

  if [[ "$fieldType" != "array" ]]; then
    msg::error "'modules' must be array"
    exit 1
  fi
  invalidTypeIndex="$(cat "$MAIN_CONFIG" | config::yq -r '.modules|map(type)|.[]' | nl -v0 -nln | grep '\(array\|object\)$' | head -n 1 | cut -d' ' -f 1)"
  if [[ "$invalidTypeIndex" != "" ]]; then
    msg::error "All items under modules must be path. Found issue with index: $invalidTypeIndex"
    cat "$MAIN_CONFIG" | config::yq -y ".modules[$invalidTypeIndex]"
    exit 1
  fi

  cat "$MAIN_CONFIG" | config::yq -r '.modules[]?'
}
