export TMPDIR=${TMPDIR:-/tmp}

load_pubkey() {
  local private_key_path=$TMPDIR/git-resource-private-key

  (jq -r '.source.private_key // empty' < $1) > $private_key_path

  if [ -s $private_key_path ]; then
    chmod 0600 $private_key_path

    eval $(ssh-agent) >/dev/null 2>&1
    trap "kill $SSH_AGENT_PID" 0

    SSH_ASKPASS=$(dirname $0)/askpass.sh DISPLAY= ssh-add $private_key_path >/dev/null

    mkdir -p ~/.ssh
    cat > ~/.ssh/config <<EOF
StrictHostKeyChecking no
LogLevel quiet
EOF
    chmod 0600 ~/.ssh/config
  fi
}

configure_git_global() {
  local git_config_payload="$1"
  eval $(echo "$git_config_payload" | \
    jq -r ".[] | \"git config --global '\\(.name)' '\\(.value)'; \"")
}

configure_git_ssl_verification() {
  skip_ssl_verification=$(jq -r '.source.skip_ssl_verification // false' < $1)
  if [ "$skip_ssl_verification" = "true" ]; then
    export GIT_SSL_NO_VERIFY=true
  fi
}

configure_credentials() {
  local username=$(jq -r '.source.username // ""' < $1)
  local password=$(jq -r '.source.password // ""' < $1)

  rm -f $HOME/.netrc
  if [ "$username" != "" -a "$password" != "" ]; then
    echo "default login $username password $password" > $HOME/.netrc
  fi
}

prepare_repository() {
  local destination="$1"
  local payload="$2"

  log "Configuring git credentials"
  load_pubkey "$payload"
  configure_git_ssl_verification "$payload"
  configure_credentials "$payload"

  log "Parsing payload"
  uri=$(jq -r '.source.uri // ""' < "$payload")
  branch=$(jq -r '.source.branch // ""' < "$payload")
  git_config_payload=$(jq -r '.source.git_config // []' < "$payload")

  configure_git_global "${git_config_payload}"

  if [ -z "$uri" ]; then
    log "invalid payload (missing uri):" "$(cat $payload)"
    exit 1
  fi

  if [ ! -d "$destination/.git" ]; then
    log "Cloning $uri in $destination"

    branchflag=""
    if [ -n "$branch" ]; then
      branchflag="--branch $branch"
    fi

    git clone --single-branch "$uri" $branchflag "$destination"
  fi

  cd "$destination"

  # first remove all local tags, only remote tags are refetched later
  git tag -l | xargs git tag -d
  git fetch --tags

  git fetch --prune
  git reset --hard FETCH_HEAD
}

bump_version() {
  local version="$1"
  local payload="$2"

  # build a file containing the correct tag based on a provided strategy (see README for versioning semantics)
  bump=$(jq -r '.params.bump // ""' < "$payload")
  pre=$(jq -r '.params.pre // ""' < "$payload")

  error_patch_breaking() {
    log "You can't have breaking changes for a patch! Commits for both are included in $version..$(git rev-parse HEAD)"
    exit 1
  }

  if [ "$bump" == "auto" ]; then
    log "Scanning commits for [breaking] or [patch] to auto bump current version $version"
    # analyse commits and if it contains [breaking] or [patch] switch the bump level, default is minor
    bump="minor"
    messages=$(git log --pretty=%s $version..HEAD 2>/dev/null | cat)
    if [ -n "$messages" ]; then
      while read message; do
        if echo "$message" | grep -Ec "\[breaking\]" > /dev/null; then
          log "Found breaking commit message: $message"
          if [ "$bump" == "patch" ]; then error_patch_breaking; fi
          bump="major"
        fi
        if echo "$message" | grep -Ec "\[patch\]" > /dev/null; then
          log "Found patch commit message: $message"
          if [ "$bump" == "major" ]; then error_patch_breaking; fi
          bump="patch"
        fi
      done <<< "$messages"
    else
      log "No messages found between $version..HEAD"
    fi
  fi

  if [ -n "$pre" ]; then
    if [ -z "$bump" ]; then
      bump="release"
    fi
    bump="pre$bump"
  fi

  # calculate next version
  if [ -n "$bump" ]; then
    log "Bumping version $version with level '$bump' (and preid '$pre')"
    semver "$version" -i "$bump" --preid "$pre"
  else
    log "Skipping bump because no bump level is defined"
    echo "$version"
  fi
}
