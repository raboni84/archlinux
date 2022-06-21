#!/usr/bin/env bash

set -u -o pipefail -o errtrace +o history
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

7z a -up0q0r2x1y2z1w2 packer.zip *.json bootstrap* userbase* package* rescue* localmirror* pxeserver* pipeline.sh pack.sh README.md LICENSE
md5sum *.json bootstrap* userbase* package* rescue* localmirror* pxeserver* pipeline.sh pack.sh README.md LICENSE > packer.md5.txt
sha1sum *.json bootstrap* userbase* package* rescue* localmirror* pxeserver* pipeline.sh pack.sh README.md LICENSE > packer.sha1.txt
