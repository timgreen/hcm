#!/bin/bash

BASE="$(dirname "$(readlink -f "$0")")"

[ -z "$INIT_CONFIG" ]      && source "$BASE/lib_config.sh"
[ -z "$INIT_MSG" ]         && source "$BASE/lib_msg.sh"

main() {
  config::load_and_cache
  config::verify
}

[[ "$DEBUG" != "" ]] && set -x
set -euf -o pipefail
main "$@"
