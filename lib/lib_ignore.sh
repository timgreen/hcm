should_ignore_file() {
  path="${1:1}"
  [[ "$path" == "HCM_MODULE" ]] || \
    [[ "$path" == "README" ]] || \
    [[ "$path" == README.* ]]
}
