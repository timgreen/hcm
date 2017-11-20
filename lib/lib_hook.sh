INIT_HOOK=true

[ -z "$INIT_DRY_RUN" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_dry_run.sh
[ -z "$INIT_SHELL" ]   && source "$(dirname "${BASH_SOURCE[0]}")"/lib_shell.sh
[ -z "$INIT_CONFIG" ]  && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh

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

hook::run_hook() {
  local absModulePath="$1"
  local hook="$2"

  local hookCmd="$(config::get_module_hook "$absModulePath" "$hook")"
  if [ -z "$hookCmd" ] || [[ "$hookCmd" == "null" ]]; then
    return
  fi

  (
    case "$(config::get_shell)" in
      bash)
        shell::run_in::bash "$hookCmd"
        ;;
      zsh)
        shell::run_in::zsh "$hookCmd"
        ;;
    esac
  ) &> /dev/null
}
