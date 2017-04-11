#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib/lib_cmd.sh"

cmd="$1"
shift

set -e
[[ "$DEBUG" != "" ]] && set -x

if is_valid_cmd_name "$cmd" && [ -f "$BASE/lib/cmd_$(cmd_to_filename "$cmd").sh" ]; then
  sh "$BASE/lib/cmd_$(cmd_to_filename "$cmd").sh" "$@"
else
  sh "$BASE/lib/cmd_help.sh" "$cmd"
fi
