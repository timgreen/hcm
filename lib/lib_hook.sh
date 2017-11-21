INIT_HOOK=true

[ -z "$INIT_CONFIG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh
[ -z "$INIT_SHELL" ]  && source "$(dirname "${BASH_SOURCE[0]}")"/lib_shell.sh

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
  )
}
