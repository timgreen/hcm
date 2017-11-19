INIT_SHELL=true

[ -z "$INIT_CONFIG" ]      && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh

# Run cmd in a interactive bash that loaded .bashrc.
#
# https://superuser.com/questions/671372/running-command-in-new-bash-shell-with-rcfile-and-c
shell::run_in::bash() {
  local cmd="$1"
  bash --rcfile "$HOME/.bashrc" -ci "$cmd"
}

shell::run_in::zsh() {
  local cmd="$1"
  zsh --rcs <(echo "source $HOME/.zshrc; { $cmd }; exit $?")
}

shell::run_in::fallback() {
  local cmd="$1"
  "$(config::get_shell)" <<< "$cmd"
}
