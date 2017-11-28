INIT_FLOCK=true

[ -z "$INIT_PATH" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path_consts.sh

flock::run() {
  # if both `flock` and lock file exist.
  if which flock &> /dev/null && [ -r "$MAIN_CONFIG_FILE" ]; then
    flock -E 123 -n -x "$MAIN_CONFIG_FILE" "$@"
    exitCode=$?
    if (( $exitCode == 123 )); then
      echo >&2 "Another hcm is running?"
      exit 1
    else
      exit $exitCode
    fi
  fi

  # fallback
  "$@"
}
