POSITIONAL=()
while (( $# > 0 )); do
  case "$1" in
    -n|--dry-run)
      shift
      DRY_RUN=true
      ;;
    -f|--no-dry-run)
      shift
      DRY_RUN=false
      ;;
    *)
      POSITIONAL+=("$1") # save it in an array for later
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
