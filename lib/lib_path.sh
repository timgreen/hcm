
HCM_TARGET_DIR="${HCM_TARGET_DIR:-$HOME}"
HCM_ROOT="$HCM_TARGET_DIR/.hcm"
MODULE_FILE="HCM_MODULE"
ROOT_FILE="HCM_MCD_ROOT"

# tracking
tracking_dir_for() {
  echo "$HCM_ROOT/modules/$1"
}

tracking_files_root_for() {
  echo "$HCM_ROOT/modules/$1/config"
}

tracking_source_for() {
  echo "$HCM_ROOT/modules/$1/source"
}

hook_work_dir_for() {
  echo "$HCM_ROOT/modules/$1/hook"
}

#
module_file_for() {
  echo "$1/$MODULE_FILE"
}

# Test functions
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

is_in_hcm_root() {
  [[ "${1:0:${#HCM_ROOT}}" == "$HCM_ROOT" ]]
}

relative_path_for_tracking_file() {
  echo "${1:${#HCM_ROOT}}" | sed 's|^/modules/[^/]\+/config/||'
}

relative_path_for_target_file() {
  echo "${1:${#HCM_TARGET_DIR}}" | sed 's|^/||'
}
