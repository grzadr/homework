#!/bin/bash

set -eux
set -o pipefail

DOCKER_BUILD=true
DOCKER_NAME='grzadr/homework'

while getopts 'd' OPTION; do
  case "$OPTION" in
    d)
      DOCKER_BUILD=false
      echo "Docker build disables" >&2
      ;;
    ?)
      echo "script usage: $(basename $0) [-d]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ DOCKER_BUILD == true ]]; then
    docker build -t "${DOCKER_NAME}" --no-cache .
fi

mkdir -p outputs

docker run -v $(pwd)/src:/root/src grzadr/homework -c 'src/export_csv_bash.sh data_sample.log' > outputs/exported_bash.csv

echo "Done" >&2