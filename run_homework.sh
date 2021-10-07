#!/bin/bash

set -eux
set -o pipefail

DOCKER_BUILD=false
DOCKER_NAME='grzadr/homework'

while getopts 'b' OPTION; do
  case "$OPTION" in
    b)
      DOCKER_BUILD=true
      echo "Docker build enabled" >&2
      ;;
    ?)
      echo "script usage: $(basename $0) [-d]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ $DOCKER_BUILD == true ]]; then
    docker build -t "${DOCKER_NAME}" --no-cache .
fi

mkdir -p outputs

time docker run \
  -v $(pwd)/src:/root/src grzadr/homework \
  -c 'src/export_csv_bash.sh data_sample.log' > outputs/exported_bash.csv

time docker run \
  -v $(pwd)/src:/root/src grzadr/homework \
  -c 'python src/export_csv_python.py data_sample.log' > outputs/exported_python.csv

echo "Done" >&2