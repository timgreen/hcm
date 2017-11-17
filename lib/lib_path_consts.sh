INIT_PATH_CONSTS=true

[ -z "$INIT_PATH" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path.sh

HCM_HOME="$HOME/.hcm"
MAIN_CONFIG_FILE="$HCM_HOME/hcm.yml"
MAIN_CONFIG_REAL_PATH="$(path::abs_readlink "$MAIN_CONFIG_FILE")"
MODULE_CONFIG="module.yml"
HCM_INSTALLED_MODULES_ROOT="$HCM_HOME/installed_modules"
