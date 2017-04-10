
HCM_TARGET_DIR="${HCM_TARGET_DIR:-$HOME}"
HCM_ROOT="$HCM_TARGET_DIR/.hcm"
MODULE_FILE="HCM_MODULE"
ROOT_FILE="HCM_MCD_ROOT"

is_cm() {
  local dir="$1"
  # cm dir should contains a regular file: $MODULE_FILE
  [ -f "$dir/$MODULE_FILE" ] && [ ! -L "$dir/$MODULE_FILE" ]
}

is_root() {
  local dir="$1"
  # root dir should contains a regular file: $ROOT_FILE
  [ -f "$dir/$ROOT_FILE" ] && [ ! -L "$dir/$ROOT_FILE" ]
}

is_same_path() {
  [[ "$(readlink -f "$1")" == "$(readlink -f "$2")" ]]
}
