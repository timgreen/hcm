INIT_PATH_CONSTS=true

[ -z "$INIT_PATH" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path.sh

readonly HCM_HOME="$HOME/.hcm"
readonly MAIN_CONFIG_FILE="$HCM_HOME/hcm.yml"
readonly MAIN_CONFIG_REAL_PATH="$(path::abs_readlink "$MAIN_CONFIG_FILE")"
readonly MODULE_CONFIG="module.yml"
readonly HCM_INSTALLED_MODULES_ROOT="$HCM_HOME/installed_modules"
