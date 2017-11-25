INIT_SYNC=true

STATUS_NEW='new'
STATUS_UP_TO_DATE='up-to-date'
STATUS_UPDATED='updated'

[ -z "$INIT_CONFIG" ]      && source "$(dirname "${BASH_SOURCE[0]}")"/lib_config.sh
[ -z "$INIT_DRY_RUN" ]     && source "$(dirname "${BASH_SOURCE[0]}")"/lib_dry_run.sh
[ -z "$INIT_HOOK_HELPER" ] && source "$(dirname "${BASH_SOURCE[0]}")"/hook_helper.sh
[ -z "$INIT_PATH_CONSTS" ] && source "$(dirname "${BASH_SOURCE[0]}")"/lib_path_consts.sh
[ -z "$INIT_SHELL" ]       && source "$(dirname "${BASH_SOURCE[0]}")"/lib_shell.sh
[ -z "$INIT_TOOLS" ]       && source "$(dirname "${BASH_SOURCE[0]}")"/lib_tools.sh

sync::check_module_status() {
  local absModulePath="$1"
  local moduleTrackBase="$(config::to_module_track_base "$absModulePath")"
  if [ ! -d "$moduleTrackBase" ]; then
    echo "$STATUS_NEW"
  elif diff -r --no-dereference "$absModulePath" "$(config::backup_path_for "$moduleTrackBase")" &> /dev/null; then
    echo "$STATUS_UP_TO_DATE"
  else
    echo "$STATUS_UPDATED"
  fi
}

# Get the list of installed modules which no longer mentioned in the main
# config.
sync::list_the_modules_need_remove() {
  {
    config::get_module_list | while read absModulePath; do
      local moduleTrackBase="$(config::to_module_track_base "$absModulePath")"
      echo "$moduleTrackBase"
      echo "$moduleTrackBase"
    done
    find "$HCM_INSTALLED_MODULES_ROOT" -maxdepth 1 -mindepth 1 -type d 2> /dev/null
  } | tools::sort | uniq -u
}

# Returns true if the given module is ready to install.
sync::ready_to_install() {
  local absModulePath="$1"
  # Ensure all the modules listed in '.after' have been installed.
  while read absAfterModulePath; do
    [ -z "$absAfterModulePath" ] && continue
    if [[ "$(sync::check_module_status "$absAfterModulePath")" != "$STATUS_UP_TO_DATE" ]]; then
      return 1
    fi
  done <<< "$(config::get_module_after_list "$absModulePath")"
  # Ensure all the cmd listed in '.requires' can be found.
  while read requiredCmd; do
    [ -z "$requiredCmd" ] && continue
    sync::is_cmd_available "$requiredCmd" || return 1
  done <<< "$(config::get_module_requires_list "$absModulePath")"
}

# Return true if then given cmd is available in the current shell environment.
sync::is_cmd_available() {
  local cmd="$1"
  (
    case "$(config::get_shell)" in
      bash)
        shell::run_in::bash "type -t '$cmd'" | grep '\(alias\|function\|builtin\|file\)'
        ;;
      zsh)
        shell::run_in::zsh "whence -w '$cmd'" | grep '\(alias\|function\|builtin\|command\)'
        ;;
    esac
  ) &> /dev/null
}

sync::install() {
  local absModulePath="$1"
  IFS=$'\n'
  for file in $(sync::install::_list "$absModulePath"); do
    dryrun::action link "$absModulePath/$file" "$HOME/$file"
  done
}

sync::install::_list() {
  local absModulePath="$1"
  (
    cd "$absModulePath"

    # Print the list of all files, -P never follow symlinks.
    find -P . \( -type l -o -type f \)

    # Everything printed again below will be filtered out by `sort | uniq -u`.

    # Ignore $MODULE_CONFIG
    echo ./$MODULE_CONFIG

    # Ignore all .hcmignore files
    find -P . \( -type l -o -type f \) -name .hcmignore

    # Concatenate a listing of all .hcmignore files, with the path to the
    # ignore file it came from prefixed to each pattern
    {
      # Process all directories with a .hcmignore file
      find -P . \( -type l -o -type f \) -name .hcmignore | \
        while read hcmignoreFile; do
          local dir="$(dirname "$hcmignoreFile")"
          # Prefix the contents of each .hcmignore file with the path
          # to the file it came from
          sed 's|^|'"$dir/"'|' "$dir"/.hcmignore
        done

      # And finally, print out all of the files that match each of the
      # patterns from all .hcmignore files. Using find and the -path
      # option allows us to respect the relative placement of each
      # pattern in the directory hiearchy.
    } | xargs -n1 find -P . -type f -path 2>/dev/null
  ) | tools::sort | uniq -u | cut -c3-
}

sync::finish_install() {
  local absModulePath="$1"
  local moduleTrackBase="$(config::to_module_track_base "$absModulePath")"
  # sort the file for deterministic result
  local linkLog="$(config::link_log_path_for "$moduleTrackBase")"
  if [ -r "$linkLog" ]; then
    tools::sort "$linkLog" -o "$linkLog"
  fi
  # Make a copy of the installed module, this is needed for uninstall. So even the
  # user deleted and orignal copy, hcm still knows how to uninstall it.
  local moduleBackupPath="$(config::backup_path_for "$moduleTrackBase")"
  mkdir -p "$(dirname "$moduleBackupPath")"
  if which rsync &> /dev/null; then
    rsync -r --links "$absModulePath/" "$moduleBackupPath"
  else
    rm -fr "$moduleBackupPath"
    cp -d -r "$absModulePath" "$moduleBackupPath"
  fi
  # Save metadata
  local metadataFile="$(config::metadata_file_for "$moduleTrackBase")"
  echo "path: $absModulePath" > "$metadataFile"
}

sync::uninstall() {
  local moduleTrackBase="$1"
  local linkLog="$(config::link_log_path_for "$moduleTrackBase")"
  cat "$linkLog" 2> /dev/null | while read linkTarget; do
    dryrun::action unlink "$HOME/$linkTarget"
    # rmdir still might fail when it doesn't have permission to remove the
    # directory, so ignore the error here.
    dryrun::action rmdir --ignore-fail-on-non-empty --parents "$(dirname "$HOME/$linkTarget")" 2> /dev/null || echo -n
  done
  dryrun::internal_action rm -f "$linkLog"
}
