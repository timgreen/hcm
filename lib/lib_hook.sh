INIT_HOOK=true

[ -z "$INIT_DRY_RUN" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_dry_run.sh

hook::install() {
  local absModulePath="$1"
  hook::_do_link_all "$absModulePath" "$absModulePath"
}

hook::_do_link_all() {
  local absModulePath="$1"
  local dir="$2"

  IFS=$'\n'
  for file in $(find -P "$dir" \( -type l -o -type f \)); do
    hook::_do_link "$absModulePath" "$file"
  done
}

hook::_do_link() {
  local absModulePath="$1"
  local file="$2"
  local relativeFilePath="${file#$absModulePath/}"

  # ignore module config
  if [[ "$MODULE_CONFIG" == "$relativeFilePath" ]]; then
    return
  fi

  dryrun::action link "$file" "$HOME/$relativeFilePath"
}

