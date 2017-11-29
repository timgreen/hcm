INIT_FUNC=true

# https://stackoverflow.com/questions/1203583/how-do-i-rename-a-bash-function#answer-18839557
func::copy() {
  test -n "$(declare -f $1)"
  eval "${_/$1/$2}"
}

func::rename() {
  func::copy $@
  unset -f $1
}

func::cache_nullary() {
  local cacheName="$1"
  local funcName="$2"
  local funcRenamed="$funcName::_renamed"

  func::rename "$funcName" "$funcRenamed"
  eval "$(cat <<EOF
    $cacheName="-"
    $funcName() {
      [[ "\$$cacheName" == "-" ]] && {
        $cacheName="\$($funcRenamed)"
      }
      echo "\$$cacheName" | sed '/^$/d'
    }
EOF
  )"
}

func::cache_unary() {
  local cacheName="$1"
  local funcName="$2"
  local funcRenamed="$funcName::_renamed"

  func::rename "$funcName" "$funcRenamed"
  eval "$(cat <<EOF
    declare -gA $cacheName
    $cacheName=()
    $funcName() {
      [ \${$cacheName[\$1]+_} ] || {
        $cacheName[\$1]="\$($funcRenamed "\$1")"
      }
      echo "\${$cacheName[\$1]}" | sed '/^$/d'
    }
EOF
  )"
}
