#!/bin/bash
##### -*- mode:shell-script; indent-tabs-mode:nil; sh-basic-offset:2 -*-
##### Author: Travis Cross <tc@traviscross.com>

#set -xv

err () {
  echo "$1" 1>&2
  exit 1
}

ssh_args=""
while getopts "p:" o; do
  case "$o" in
    p) ssh_args="-p $OPTARG" ;;
  esac
done
shift $(($OPTIND-1))

url="$1"
script="$2"

if test $# -lt 1 || test -z "$url"; then
  err "Usage: $0 <ssh-url> [<local-script>]"
fi

remote_command () {
  ssh $ssh_args "$url" "$1"
}

remote_run () {
  remote_command \
    "rf=\$(mktemp /tmp/remote-run-XXXXXXXX); \
cat > \$rf && chmod +x \$rf && \$rf; rm -f \$rf"
}

if test -n "$script"; then
  cat "$script" | remote_run
else
  remote_run
fi
