#!/usr/bin/env bash

set -uo pipefail
set +o history
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

7z a -up0q0r2x1y2z1w2 packer.7z *.json bootstrap* userbase* package* pipeline.sh pack.sh
md5sum *.json bootstrap* userbase* package* pipeline.sh pack.sh packer.7z > packer.md5.txt
sha1sum *.json bootstrap* userbase* package* pipeline.sh pack.sh packer.7z > packer.sha1.txt
