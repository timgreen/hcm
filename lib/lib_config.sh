INIT_CONFIG=true

[ -z "$INIT_MSG" ]         && source "$(dirname "${BASH_SOURCE[0]}")"/lib_msg.sh
[ -z "$INIT_PATH" ]        && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path.sh
[ -z "$INIT_PATH_CONSTS" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path_consts.sh
[ -z "$INIT_TOOLS" ]       && source "$(dirname "${BASH_SOURCE[0]}")"/lib_tools.sh

config::get_shell() {
  local scriptShell="$(cat "$MAIN_CONFIG_FILE" | tools::yq -r .shell)"
  case "$scriptShell" in
    bash|null|'')
      echo bash
      ;;
    zsh)
      echo zsh
      ;;
    *)
      msg::error "Unsupported shell: $scriptShell, currently only support bash & zsh."
      exit 1
      ;;
  esac
}

CACHED_MODULE_LIST=""
# Returns the abs path for modules.
config::get_module_list() {
  [ -z "$CACHED_MODULE_LIST" ] && {
    CACHED_MODULE_LIST="$(
      cat "$MAIN_CONFIG_FILE" | tools::yq -r '.modules[]?' | while read modulePath; do
        # output absModulePath
        path::abs_path_for --relative-base-file "$MAIN_CONFIG_REAL_PATH" "$modulePath"
      done | tools::sort
    )"
  }
  echo "$CACHED_MODULE_LIST" | sed '/^$/d'
}

config::_ensure_string_array_for_field() {
  local configPath="$1"
  local fieldPath="$2"

  local fieldType="$(cat "$configPath" | tools::yq -r "([$fieldPath]|map(type))[0]")"
  [[ "$fieldType" == "" ]] && return
  [[ "$fieldType" == "null" ]] && return

  if [[ "$fieldType" != "array" ]]; then
    msg::error "Field '$fieldPath' must be array.\nFound errors in $configPath"
    exit 1
  fi
  local invalidTypeIndex="$(cat "$configPath" | tools::yq -r "$fieldPath|map(type)|.[]" | nl -v0 -nln | grep '\(array\|object\)$' | head -n 1 | cut -d' ' -f 1)"
  if [[ "$invalidTypeIndex" != "" ]]; then
    msg::error "All items under field '$fieldPath' must be string. Found issue with index: $invalidTypeIndex"
    msg::error "In file: $configPath"
    cat "$configPath" | tools::yq -y "$fieldPath[$invalidTypeIndex]"
    exit 1
  fi
}

config::verify::_main() {
  config::_ensure_string_array_for_field "$MAIN_CONFIG_FILE" ".modules"
}

config::verify::_module() {
  local absModulePath="$1"
  if [ -z "$absModulePath" ] || [ ! -d "$absModulePath" ]; then
    msg::error "Invalid module '$absModulePath', directory not exist."
    exit 1
  fi
  local absModuleConfigPath="$absModulePath/$MODULE_CONFIG"
  if [ ! -r "$absModuleConfigPath" ]; then
    msg::error "Invalid module '$absModulePath', cannot read module config $absModuleConfigPath."
    exit 1
  fi

  # .after
  config::_ensure_string_array_for_field "$absModuleConfigPath" ".after"
  ## Ensure all the module listed in `after` are mentioned in the main config.
  config::get_module_after_list "$absModulePath" | while read absAfterModulePath; do
    grep --fixed-strings --line-regexp "$absAfterModulePath" <<<"$(config::get_module_list)" &> /dev/null || {
      msg::error "Depends on invalid module that not mentioned in main config."
      msg::info "module config: $absModuleConfigPath"
      msg::info "invalid module listed in .after: $absAfterModulePath"
      exit 1
    }
  done

  # .requires
  config::_ensure_string_array_for_field "$absModuleConfigPath" ".requires"
}

config::verify::_dependencies() {
  # Use `tsort` to do topological sort.
  config::get_module_list | while read absModulePath; do
    config::get_module_after_list "$absModulePath" | while read absAfterModulePath; do
      echo "$absModulePath" | tr ' ' '_'
      echo "$absAfterModulePath" | tr ' ' '_'
    done
  done | tsort > /dev/null
}

config::verify() {
  [ -r "$MAIN_CONFIG_FILE" ] || {
    msg::error 'Cannot read main config "$HOME/.hcm/hcm.yml".'
    exit 1
  }

  config::verify::_main
  config::get_module_list | while read absModulePath; do
    config::verify::_module "$absModulePath"
  done
  config::verify::_dependencies
}

# use md5 as track base name, so we have a flat structure under $HOME/.hcm/installed_modules/
config::to_module_track_base() {
  local absModulePath="$1"
  local flattenName="$(echo "$absModulePath" | md5sum | cut -c 1-32)"
  echo "$HCM_INSTALLED_MODULES_ROOT/$flattenName"
}

config::backup_path_for() {
  local moduleTrackBase="$1"
  echo "$moduleTrackBase/module"
}

config::link_log_path_for() {
  local moduleTrackBase="$1"
  echo "$moduleTrackBase/link.log"
}

config::metadata_file_for() {
  local moduleTrackBase="$1"
  echo "$moduleTrackBase/metadata.yml"
}

config::get_module_after_list() {
  local absModulePath="$1"
  local absModuleConfigPath="$absModulePath/$MODULE_CONFIG"
  cat "$absModuleConfigPath" | tools::yq -r '.after[]?' | while read afterModulePath; do
    # output absAfterModulePath
    path::abs_path_for --relative-base-file "$absModuleConfigPath" "$afterModulePath"
  done
}

config::get_module_requires_list() {
  local absModulePath="$1"
  local absModuleConfigPath="$absModulePath/$MODULE_CONFIG"
  cat "$absModuleConfigPath" | tools::yq -r '.requires[]?'
}

config::get_module_hook() {
  local absModulePath="$1"
  local hook="$2"
  local absModuleConfigPath="$absModulePath/$MODULE_CONFIG"
  cat "$absModuleConfigPath" | tools::yq -r ".\"$hook\"?"
}
