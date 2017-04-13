#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_path.sh"
source "$BASE/lib_msg.sh"
source "$BASE/lib_ignore.sh"
source "$BASE/lib_hook_exit_status.sh"

process_sub_dir() {
  local dir="$1"

  if is_cm "$dir"; then
    process_cm "$dir"
  else
    local is_empty_dir=true
    for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
      process_sub_dir "$sub_dir"
      is_empty_dir=false
    done

    for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
      error_msg "unmanaged file: $file"
      exit 1
    done

    $is_empty_dir && {
      error_msg "empty dir: $dir"
      exit 1
    }
  fi
}

process_root() {
  local dir="$1"

  for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
    process_sub_dir "$sub_dir"
  done

  for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
    is_same_path "$dir/$ROOT_FILE" "$file" && continue

    error_msg "unmanaged file: $file"
    exit 1
  done
}

link_configs() {
  local relative_path="$1"
  local source_dir="$2"
  local tracking_dir="$3"
  local target_dir="$4"

  # we link all new files in the source dir.
  for file in $(find -P "$source_dir/" -maxdepth 1 -mindepth 1 -type f; find -P "$source_dir/" -maxdepth 1 -mindepth 1 -type l); do
    local file_basename="$(basename "$file")"
    should_ignore_file "$relative_path/$file_basename" && continue
    maybe_link_new_config "$file" "$tracking_dir/$file_basename" "$target_dir/$file_basename"
  done

  # last, handle the subdirectories recusively.
  for sub in $(find -P "$source_dir/" -maxdepth 1 -mindepth 1 -type d); do
    local sub_basename="$(basename "$sub")"
    link_configs "$relative_path/$sub_basename" "$sub" "$tracking_dir/$sub_basename" "$target_dir/$sub_basename"
  done
}

maybe_link_new_config() {
  local source_file="$1"
  local tracking_file="$2"
  local target_file="$3"

  # <source> <tracking> <target>
  ##############################################################################
  #    x         s               link tracking -> target
  #    x         s         s     no-op
  #    x                         link source -> tracking -> target
  ##############################################################################
  # NOTE: we already handled most of the conflict cases
  #    x                   s     link source -> tracking
  #              m               rm tracking
  #              m         m     rm tracking; rm target
  #                        m     rm target (skipped if target is $HCM_TARGET_DIR for performance reason)
  #    x         s         c     error
  #    x         c               link (force) source -> tracking -> target
  #    x         c         c     link (force) source -> tracking -> target
  #    x         c1        c2    error
  #              m         c     rm tracking; error

  if [ ! -L "$target_file" ] && [ -d "$target_file" ]; then
    error_msg "can not install '$source_file' as '$target_file', target is a directory"
    exit 1
  fi

  if [ ! -e "$tracking_file" ]; then
    mkdir -p "$(dirname "$tracking_file")"
    ln -s "$source_file" "$tracking_file"
  fi
  is_same_path "$source_file" "$tracking_file" || {
    error_msg "internal error, can not install '$source_file'"
    exit 1
  }

  if [ ! -e "$target_file" ]; then
    mkdir -p "$(dirname "$target_file")"
    ln -s "$tracking_file" "$target_file"
  fi
  is_same_path "$tracking_file" "$target_file" || {
    error_msg "can not install '$source_file':\nconflict with target file '$target_file'"
    exit 1
  }
}

process_cm() {
  local dir="$1"
  local name="$(basename "$dir")"

  local tracking_dir="$(tracking_dir_for "$name")"
  mkdir -p "$(tracking_files_root_for "$name")"

  info "Install CM: '$dir' ..."

  if [ ! -e "$(tracking_source_for "$name")" ]; then
    ln -s "$dir" "$(tracking_source_for "$name")"
  fi

  if [ ! -L "$(tracking_source_for "$name")" ]; then
    internal_error_msg "$(tracking_source_for "$name") is not softlink"
    exit 2
  fi

  if ! is_same_path "$(tracking_source_for "$name")" "$dir"; then
    error_msg "CM conflict: $name\ncan not install $dir, already installed $(readlink -m "$(tracking_source_for "$name")")"
    exit 1
  fi

  pre_link_hook_result=$(bash "$BASE/hook.sh" "$dir" pre_link)
  pre_link_hook_status=$?
  case $pre_link_hook_status in
    $HOOK_EXIT_SKIP)
      return 0
      ;;
    $HOOK_EXIT_ACTION_NOT_FOUND|0)
      ;;
    *)
      hook_error_msg "pre_link" "$dir" "$pre_link_hook_result" "$pre_link_hook_status"
      exit 1
      ;;
  esac

  link_configs "" "$dir" "$(tracking_files_root_for "$name")" "$HCM_TARGET_DIR"
  bash "$BASE/hook.sh" "$dir" post_link || IGNORE_ERROR=x

  info "Install CM: '$dir' Done"
}

process_root_or_cm() {
  local dir="$1"
  if is_root "$dir"; then
    process_root "$dir"
  elif is_cm "$dir"; then
    process_cm "$dir"
  else
    error_msg "invalid dir: $dir"
    exit 1
  fi
}

main() {
  # Do a fast scan to remove legacy files in the $HCM_TARGET_DIR
  bash "$BASE/cmd_remove_legacy.sh" --fast-scan
  # And remove legacy files in the $HCM_ROOT
  bash "$BASE/internal_cmd_remove_legacy_tracking.sh"

  # Finally, install the new files
  if (( $# == 0 )); then
    # use CWD if <dir> is not specified
    process_root_or_cm "$(readlink -f "$PWD")"
  else
    while (( $# > 0 )); do
      local dir="$1"
      shift
      process_root_or_cm "$(readlink -f "$dir")"
    done
  fi
}

[[ "$DEBUG" != "" ]] && set -x
main "$@"
