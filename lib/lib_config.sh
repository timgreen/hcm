
HAS_YQ=$(which yq 2> /dev/null)
HAS_DOCKER=$(which docker 2> /dev/null)

yq_wrapper() {
  if [ -n "$HAS_YQ" ]; then
    yq "$@"
  elif [ -n "$HAS_DOCKER" ]; then
    docker run -i evns/yq "$@"
  else
    error_msg "yq not available"
    exit 1
  fi
}

get_shell() {
  scriptShell="$(cat "$MAIN_CONFIG" | yq_wrapper -r .shell)"
  if [[ "$scriptShell" == "" ]]; then
    echo bash
  else
    echo "$scriptShell"
  fi
}
