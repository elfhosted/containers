#!/bin/bash
autobrr_config=/config/autobrr.db
declare -a filters=(regbrr-TV regbrr-TV4K regbrr-TVDV regbrr-Movies regbrr-Movies4K regbrr-MoviesDV regbrr-BluRay regbrr-BluRay4K regbrr-BluRayDV)

bu_keep_days=3 #number of days to keep
db_path=/config/

# Grab upcoming blurays
bluray=$(
  curl -sL "https://sudoer.dev/bluray" || {
    echo "Failed to run BluRay injection."
    exit 1
  }
)

# Grab upcoming movies
movies=$(
  curl -sL "https://sudoer.dev/movies" || {
    echo "Failed to run Streaming Movies injection."
    exit 2
  }
)

shows=$(
  curl -sL "https://sudoer.dev/tv" || {
    echo "Failed to run TV injection."
    exit 3
  }
)

# Grab 7 days worth of upcoming TV shows. If they have reach 50% rating on trakt it moves there.
shows_anticipated=$(
  curl -sL "https://sudoer.dev/anticipated" || {
    echo "Failed to run Anticipated injection."
    exit 4
  }
)

release_groups=$(
  curl -sL "https://gl0ry.us/groups" || {
    echo "Failed to get release groups"
    exit 5
  }
)

sqlite3 ${autobrr_config} ".backup ${autobrr_config}.$(date +"%Y_%m_%d_%I_%M_%p").bak" || {
  echo "failed to backup db"
  exit 6
}

mov='.*mov*'
blu='.*blu*'
tv='.*tv*'
tvant='.*ant*'
group='.*group*'
# 4k='.*4k*'
# dv='.*dv*'

for i in ${filters[@]}; do
  if [[ ${i,,} =~ ${tvant} ]]; then
      sqlite3 ${autobrr_config} <<EOS
update filter set match_releases = "${shows_anticipated}" where name = "${i}";
EOS

  elif [[ ${i,,} =~ ${blu} ]]; then
      sqlite3 ${autobrr_config} <<EOS
update filter set match_releases = "${bluray}" where name = "${i}";
EOS

  elif [[  ${i,,} =~ ${mov} ]]; then
    sqlite3 ${autobrr_config} <<EOB
update filter set match_releases = "${movies}" where name = "${i}";
EOB

  elif [[  ${i,,} =~ ${group} ]]; then
    sqlite3 ${autobrr_config} <<EOC
update filter set match_release_groups = "${release_groups}" where name = "${i}";
EOC

  elif [[ ${i,,} =~ ${tv} ]]; then
    sqlite3 ${autobrr_config} <<EOD
update filter set match_releases = "${shows}" where name = "${i}";
EOD

  else
      echo "${i} did not match either movie or tv."
  fi
done

find $db_path -name "autobrr.db.20??_??_??_??_??_??.bak" -mtime +$bu_keep_days -type f -delete