INIT_TOOLS=true

[ -z "$INIT_MSG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_msg.sh

HAS_YQ=$(which yq 2> /dev/null)
HAS_DOCKER=$(which docker 2> /dev/null)

tools::yq() {
  if [ -n "$HAS_YQ" ]; then
    yq "$@"
  elif [ -n "$HAS_DOCKER" ]; then
    docker run -i evns/yq "$@"
  else
    msg::error "yq not available"
    exit 1
  fi
}

tools::sort() {
  LC_ALL=C sort "$@"
}
