#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

HCM_ROOT="$HOME/.hcm"
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

is_same_file() {
  [[ "$(readlink -f "$1")" == "$(readlink -f "$2")" ]]
}

process_sub_dir() {
  local dir="$1"
  echo "sub_dir: $1"

  if is_cm "$dir"; then
    process_cm "$dir"
  else
    local empty_dir=true
    for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
      process_sub_dir "$sub_dir"
      empty_dir=false
    done

    for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
      echo "Unmanaged file: $file"
      empty_dir=false
    done

    echo "Empty dir: $dir"
  fi
}

process_root() {
  local dir="$1"

  echo "root: $dir"

  for sub_dir in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype d); do
    process_sub_dir "$sub_dir"
  done

  for file in $(find -H "$dir" -maxdepth 1 -mindepth 1 -xtype f); do
    is_same_file "$dir/$ROOT_FILE" "$file" && continue

    echo "Unmanaged file: $file"
  done
}

link_configs() {
  local source_dir="$1"
  local tracking_dir="$2"
  local target_dir="$3"

  # <source> <tracking> <target>
  ##############################################################################
  #    x         s               link tracking -> target
  #    x         s         s     no-op
  #    x                   s     link source -> tracking
  #    x                         link source -> tracking -> target
  #              m               rm tracking
  #              m         m     rm tracking; rm target
  #                        m     rm target (skipped if target is $HOME for performance reason)
  ##############################################################################
  #    x         s         c     error
  #    x         c               link (force) source -> tracking -> target
  #    x         c         c     link (force) source -> tracking -> target
  #    x         c1        c2    error
  #              m         c     rm tracking; error

  echo "link_configs: $1 $2 $3"

  # first, check if their are directories
  # TODO

  # second, we remove all files/dirs no longer exist in the source dir.
  # By going though the items in the <tracking_dir>, for most of the cases
  # <tracking_dir> should represent the current states in the <target_dir>,
  # otherwise we need a cleanup.
  for item in $(find -P "$target_dir" -maxdepth 1 -mindepth 1); do
    maybe_remove_legacy_config "$source_dir/$item" "$tracking_dir/$item" "$target_dir/$item"
  done

  # last, we link all new files in the source dir.
  for file in $(find -P "$source_dir" -maxdepth 1 -mindepth 1 -type f); do
    maybe_link_new_config "$source_dir/$file" "$tracking_dir/$file" "$target_dir/$file"
  done

  # last, handle the subdirectories recusively.
  for sub in $(find -P "$source_dir" -maxdepth 1 -mindepth 1 -type d); do
    link_configs "$1/$sub" "$2/$sub" "$3/$sub"
  done
}

maybe_remove_legacy_config() {
  local source_item="$1"
  local tracking_item="$2"
  local target_item="$3"

  if [ -d "$target_item" ]; then
    if [ !-d "$source_item" ]; then
      # TODO: error or move all the conflict check to one place.
      return 1
    fi

    [ -e "$source_item" ] && return

    remove_legacy_config_dir "$tracking_item" "$target_item"
  else
    if [ -d "$source_item" ]; then
      # TODO: error or move all the conflict check to one place.
      return 1
    fi

    [ -e "$source_item" ] && return

    remove_legacy_config_file "$tracking_item" "$target_item"
  fi
}

remove_legacy_config_dir() {
  local tracking_dir="$1"
  local target_dir="$2"

  [ !-e "$target_dir" ] && return
  if [ !-d "$target_dir" ]; then
    # TODO: error
      return 1
  fi

  for item in $(find -P "$target_dir" -maxdepth 1 -mindepth 1); do
    if [ -d "$tracking_dir/$item" ]; then
      remove_legacy_config_dir "$tracking_dir/$item" "$target_dir/$item"
    else
      remove_legacy_config_file "$tracking_dir/$item" "$target_dir/$item"
    fi
  done

  rmdir --ignore-fail-on-non-empty "$tracking_dir"
  rmdir --ignore-fail-on-non-empty "$target_dir"
}

remove_legacy_config_file() {
  local tracking_item="$1"
  local target_item="$2"

  [ !-e "$target_item" ] && return
  if [ !-L "$target_item" ]; then
    # TODO: error
    return 1
  fi

  if [[ "$(readlink $target_item)" != "$tracking_item" ]]; then
    # TODO: error
    return 1
  fi

  unlink "$tracking_item"
  unlink "$target_item"
}

process_cm() {
  local dir="$1"
  local name="$(basename "$dir")"

  echo "cm: $dir"

  local tracking_dir="$HCM_ROOT/$name"
  mkdir -p "$tracking_dir/config"

  ln -sf "$dir" "$tracking_dir/source"

  link_configs "$dir" "$tracking_dir/config" "$HOME"
}

process_root_or_cm() {
  local dir="$1"
  if is_root "$dir"; then
    process_root "$dir"
  elif is_cm "$dir"; then
    process_cm "$dir"
  else
    echo "Invalid dir: $dir"
    exit 1
  fi
}

main() {
  if (( $# == 0 )); then
    # use CWD if <dir>
    main "$PWD"
  else
    while (( $# > 0 )); do
      local dir="$1"
      shift
      process_root_or_cm "$(readlink -f $dir)"
    done
  fi
}

main "$@"
