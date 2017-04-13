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
      error "Unmanaged file: $file"
      is_empty_dir=false
    done

    $is_empty_dir && error "Empty dir: $dir"
  fi
}

process_root() {
  local dir="$1"

  for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
    process_sub_dir "$sub_dir"
  done

  for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
    is_same_path "$dir/$ROOT_FILE" "$file" && continue

    error "Unmanaged file: $file"
  done
}

link_configs() {
  local relative_path="$1"
  local source_dir="$2"
  local tracking_dir="$3"
  local target_dir="$4"

  # we link all new files in the source dir.
  for file in $(find -P "$source_dir/" -maxdepth 1 -mindepth 1 -type f); do
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

  if [ -d "$target_file" ]; then
    error "link new config $1 $2 $3"
  fi

  if [ ! -e "$tracking_file" ]; then
    mkdir -p "$(dirname "$tracking_file")"
    ln -s "$source_file" "$tracking_file"
  fi
  is_same_path "$source_file" "$tracking_file" || {
    error "internal error, can not install '$source_file'"
  }

  if [ ! -e "$target_file" ]; then
    mkdir -p "$(dirname "$target_file")"
    ln -s "$tracking_file" "$target_file"
  fi
  is_same_path "$tracking_file" "$target_file" || {
    error "can not install '$source_file':\nconflict with target file '$target_file'"
  }
}

process_cm() {
  local dir="$1"
  local name="$(basename "$dir")"

  local tracking_dir="$(tracking_dir_for "$name")"
  mkdir -p "$(tracking_files_root_for "$name")"

  if [ ! -e "$(tracking_source_for "$name")" ]; then
    ln -s "$dir" "$(tracking_source_for "$name")"
  fi

  if [ ! -L "$(tracking_source_for "$name")" ]; then
    error "Internal error: $(tracking_source_for "$name") is not softlink"
  fi

  if ! is_same_path "$(tracking_source_for "$name")" "$dir"; then
    error "CM conflict: $name\ncan not install $dir, already installed $(readlink -m "$(tracking_source_for "$name")")"
  fi

  $(bash "$BASE/hook.sh" "$dir" pre_link) # preserve the exit status when set -e is on
  (( $? == $HOOK_EXIT_SKIP )) && return 0

  link_configs "" "$dir" "$(tracking_files_root_for "$name")" "$HCM_TARGET_DIR"
  bash "$BASE/hook.sh" "$dir" post_link || IGNORE_ERROR=x
}

process_root_or_cm() {
  local dir="$1"
  if is_root "$dir"; then
    process_root "$dir"
  elif is_cm "$dir"; then
    process_cm "$dir"
  else
    error "Invalid dir: $dir"
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
