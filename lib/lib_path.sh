INIT_PATH=true

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

