#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_path.sh"

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
    is_same_path "$dir/$ROOT_FILE" "$file" && continue

    echo "Unmanaged file: $file"
  done
}

link_configs() {
  local source_dir="$1"
  local tracking_dir="$2"
  local target_dir="$3"

  echo "link_configs: $1 $2 $3"

  # we link all new files in the source dir.
  for file in $(find -P "$source_dir" -maxdepth 1 -mindepth 1 -type f); do
    local file_basename="$(basename "$file")"
    maybe_link_new_config "$file" "$tracking_dir/$file_basename" "$target_dir/$file_basename"
  done

  # last, handle the subdirectories recusively.
  for sub in $(find -P "$source_dir" -maxdepth 1 -mindepth 1 -type d); do
    local sub_basename="$(basename "$sub")"
    link_configs "$sub" "$tracking_dir/$sub_basename" "$target_dir/$sub_basename"
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
  #                        m     rm target (skipped if target is $HOME for performance reason)
  #    x         s         c     error
  #    x         c               link (force) source -> tracking -> target
  #    x         c         c     link (force) source -> tracking -> target
  #    x         c1        c2    error
  #              m         c     rm tracking; error

  if [ -d "$target_file" ]; then
    echo "error: link new config $1 $2 $3"
    exit 1
  fi
  [ -r "$tracking_file" ] || {
    mkdir -p "$(dirname "$tracking_file")"
    ln -s "$source_file" "$tracking_file"
  }
  [ -r "$target_file" || {
    mkdir -p "$(dirname "$target_file")"
    ln -s "$tracking_file" "$target_file"
  }
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
  # Do a fast scan to remove legacy files in the $HCM_TARGET_DIR
  sh "$BASE/cmd_remove_legacy.sh" --fast-scan
  # And remove legacy files in the $HCM_ROOT
  sh "$BASE/internal_remove_legacy_tracking.sh"

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

main "$@"
