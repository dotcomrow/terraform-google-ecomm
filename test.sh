#!/bin/bash

datenum=$(expr $(date +%s) + 0)
dirstring="$((datenum % 10000))dir"
retries=5
while true; do
  res=$(mkdir $dirstring 2>&1)
  if echo "$res" | grep -Eq '^.{0}$'; then
    break
  fi
  sleep 5
  datenum=$(expr $(date +%s) + 0)
  dirstring="$((datenum % 10000))dir"
  retries=$((retries - 1))
  if [ $retries -eq 0 ]; then
    echo "Failed to create directory"
    exit 1
  fi
done



SHA=$(gcloud artifacts docker images list us-docker.pkg.dev/$2/gcr.io/$1 --sort-by="~UPDATE_TIME" --limit=1 --format="value(format('{0}',version))")

cat <<EOF
{
  "sha": "$SHA"
}
EOF