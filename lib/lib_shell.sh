INIT_SHELL=true

[ -z "$INIT_CONFIG" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh

HELPERS_ROOT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/helpers"

# Run cmd in a interactive bash.
# In which .bashrc is loaded and helpers are avaiable in the $PATH.
#
# https://superuser.com/questions/671372/running-command-in-new-bash-shell-with-rcfile-and-c
shell::run_in::bash() {
  local cmd="$1"
  bash --rcfile <(
    echo 'source "$HOME/.bashrc"'
    echo "PATH=$HELPERS_ROOT:\$PATH"
  ) -ci "$cmd"
}

# Run cmd in a interactive zsh.
# In which .zshrc is loaded and helpers are avaiable in the $PATH.
shell::run_in::zsh() {
  local cmd="$1"
  zsh --rcs <(
    echo "source $HOME/.zshrc"
    echo "path+=($HELPERS_ROOT)"
    echo "{ $cmd }"
    echo 'exit $?'
  )
}

shell::run_in::fallback() {
  local cmd="$1"
  "$(config::get_shell)" <<< "$cmd"
}
