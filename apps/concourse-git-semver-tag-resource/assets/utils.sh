log() {
  # $1: message
  # $2: json
  local message="$(date -u '+%F %T') - $1"
  if [ -n "$2" ]; then
   message+=" - $(hide_password "$2")"
  fi
  echo "$message" >&2
}

hide_password() {
  if ! echo "$1" | jq -c '.' > /dev/null 2> /dev/null; then
    echo "(invalid json: $1)>"
    exit 1
  fi

  local paths=$(echo "${1:-{\} }" | jq -c "paths")
  local query=""
  if [ -n "$paths" ]; then
    while read path; do
      local parts=$(echo "$path" | jq -r '.[]')
      local selection=""
      local found=""
      while read part; do
        selection+=".$part"
        if [ "$part" == "password" ]; then
          found="true"
        fi
      done <<< "$parts"

      if [ -n "$found" ]; then
        query+=" | jq -c '$selection = \"*******\"'"
      fi
    done <<< "$paths"
  fi

  local json="${1//\"/\\\"}"
  eval "echo \"$json\" $query"
}

copy_preserve_folder() {
  # Move specified files to a specified folder preserving directory structure.
  # Based on answers at:
  # http://stackoverflow.com/questions/1650164/bash-copy-named-files-recursively-preserving-folder-structure
  local length=$(($#-1))
  local array=${@:1:$length}

  if [ ${#@} -lt 2 ]; then
    log "USAGE: copy_preserve_folder file [file file ...] directory"
  else
    tar cf - $array | (cd ${@:${#@}} ; tar xf -)
  fi
}
