INIT_PATH=true

[ -z "$INIT_MSG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_msg.sh

# Why not just `realpath --relative-to=A B`?
#
# 1. realpath will resolve B if it is a softlink, but I prefer not.
# 2. in some old system, realpath dont have --relative-to option
#
# Returns the relative path to $a for $b.
#
# NOTE, this function assume both $a & $b is abs path and $a ends with '/'.
path::relative_to() {
  local a="$1"
  local b="$2"
  local prefix="$3"

  if [[ "$b" = "$a"* ]]; then
    echo "$prefix${b#$a}"
  else
    path::relative_to "$(dirname "$a")/" "$b" "../$prefix"
  fi
}

# "Usage: abs_path_for [--relative-base-file <file> | --relative-base-dir <dir>] <path>"
#
# Return the abs path for <path> based on relative base dir or file.
path::abs_path_for() {
  local relativeBase=""
  local positional=()
  while (( $# > 0 )); do
    case "$1" in
      --relative-base-dir)
        shift
        relativeBase="$1"
        shift
        ;;
      --relative-base-file)
        shift
        relativeBase="$(dirname "$1")"
        shift
        ;;
      *)
        positional+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${positional[@]}" # restore positional parameters

  if (( $# != 1 )) || [ -z "$relativeBase" ]; then
    msg::error "Wrong parameters"
    msg::info "Usage: abs_path_for [--relative-base-file <file> | --relative-base-dir <dir>] <path>"
    exit 1
  fi

  (
    cd "$relativeBase"
    realpath --no-symlinks -m "$1"
  )
}
