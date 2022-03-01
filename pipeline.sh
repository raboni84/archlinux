#!/usr/bin/env bash

set -uo pipefail
set +o history
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

yearmonth=$(date -d "`date +%Y%m%d` - 4 days" +%Y.%m)
bootonly=""
withpxe=""
forcebuild=""
graphicalenv="YES"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -b|--bootonly)
      bootonly="YES"
      shift
      ;;
    -p|--withpxe)
      withpxe="YES"
      shift
      ;;
    -f|--forcebuild)
      forcebuild="YES"
      shift
      ;;
    -ng|--no-graphical-env)
      graphicalenv=""
      shift
      ;;
    *)
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

wget --server-response --timestamping "https://ftp.halifax.rwth-aachen.de/archlinux/iso/${yearmonth}.01/archlinux-${yearmonth}.01-x86_64.iso"
wget --server-response --timestamping "https://ftp.halifax.rwth-aachen.de/archlinux/iso/${yearmonth}.01/archlinux-bootstrap-${yearmonth}.01-x86_64.tar.gz"
wget --server-response --timestamping "https://ftp.halifax.rwth-aachen.de/archlinux/iso/${yearmonth}.01/sha1sums.txt"
while read line; do
    if [ ! -z "$line" ]; then
        echo $line | sha1sum -c -
    fi
done < sha1sums.txt

mkdir -p output pxe

if [[ ${graphicalenv} =~ "YES" ]]; then
  if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*bootstrap-desktop*.ova" -type f)" ]; then
    yearmonth=$yearmonth packer build -force -var-file=arch-bootstrap-vars.json -only=bootstrap archlinux.json
  fi
else
  if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*bootstrap-console*.ova" -type f)" ]; then
    yearmonth=$yearmonth packer build -force -var-file=arch-bootstrap-ng-vars.json -only=bootstrap archlinux.json
  fi
fi

if [[ -z ${bootonly} ]]; then
  if [[ ${graphicalenv} =~ "YES" ]]; then
    if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*userbase-desktop*.ova" -type f)" ]; then
      yearmonth=$yearmonth packer build -force -var-file=arch-userbase-vars.json -only=customize archlinux.json
    fi
    if [[ ${withpxe} =~ "YES" ]]; then
      yearmonth=$yearmonth packer build -force -var-file=arch-pxe-userbase-vars.json -only=pxeboot archlinux.json
    fi
  else
    if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*userbase-console*.ova" -type f)" ]; then
      yearmonth=$yearmonth packer build -force -var-file=arch-userbase-ng-vars.json -only=customize archlinux.json
    fi
    if [[ ${withpxe} =~ "YES" ]]; then
      yearmonth=$yearmonth packer build -force -var-file=arch-pxe-userbase-ng-vars.json -only=pxeboot archlinux.json
    fi
  fi
fi
