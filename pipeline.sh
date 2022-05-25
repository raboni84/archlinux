#!/usr/bin/env bash

set -uo pipefail
set +o history
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

yearmonthday=$(curl -sL "https://archlinux.org/download/" | xmllint --html --xpath '/html/body/div[2]/div[2]/ul[1]/li[1]/text()' - 2>/dev/null | xargs)
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

wget --server-response --timestamping "https://ftp.halifax.rwth-aachen.de/archlinux/iso/${yearmonthday}/archlinux-${yearmonthday}-x86_64.iso"
wget --server-response --timestamping "https://ftp.halifax.rwth-aachen.de/archlinux/iso/${yearmonthday}/archlinux-bootstrap-${yearmonthday}-x86_64.tar.gz"
wget --server-response --timestamping "https://ftp.halifax.rwth-aachen.de/archlinux/iso/${yearmonthday}/sha1sums.txt"
while read line; do
    if [ ! -z "$line" ]; then
        echo $line | sha1sum -c -
    fi
done < sha1sums.txt

if [[ ${graphicalenv} =~ "YES" ]]; then
  if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*bootstrap-desktop*.ovf" -type f)" ]; then
    yearmonthday=$yearmonthday packer build -force -var-file=arch-bootstrap-vars.json -only=bootstrap archlinux.json
  fi
else
  if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*bootstrap-console*.ovf" -type f)" ]; then
    yearmonthday=$yearmonthday packer build -force -var-file=arch-bootstrap-ng-vars.json -only=bootstrap archlinux.json
  fi
fi

if [[ -z ${bootonly} ]]; then
  if [[ ${graphicalenv} =~ "YES" ]]; then
    if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*userbase-desktop*.ovf" -type f)" ]; then
      yearmonthday=$yearmonthday packer build -force -var-file=arch-userbase-vars.json -only=customize archlinux.json
    fi
    if [[ ${withpxe} =~ "YES" ]]; then
      yearmonthday=$yearmonthday packer build -force -var-file=arch-pxe-userbase-vars.json -only=pxeboot archlinux.json
    fi
  else
    if [[ ${forcebuild} =~ "YES" ]] || [ -z "$(find output -name "*userbase-console*.ovf" -type f)" ]; then
      yearmonthday=$yearmonthday packer build -force -var-file=arch-userbase-ng-vars.json -only=customize archlinux.json
    fi
    if [[ ${withpxe} =~ "YES" ]]; then
      yearmonthday=$yearmonthday packer build -force -var-file=arch-pxe-userbase-ng-vars.json -only=pxeboot archlinux.json
    fi
  fi
fi
