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
file="$2"
target="$3"

if test $# -lt 2 || test -z "$url"; then
  err "Usage: $0 <ssh-url> [<local-file>] <remote-file>"
fi

if test $# -eq 2; then
  file=""
  target="$2"
fi

remote_command () {
  ssh $ssh_args "$url" "$1"
}

remote_run () {
  remote_command \
    "rf=\$(mktemp /tmp/remote-run-XXXXXXXX); \
cat > \$rf && chmod +x \$rf && \$rf; rm -f \$rf"
}

put_file () {
  rnd="dxtdlielaecykeoqgsasirpbuclxjfnuidojetbdniirbmuzuapaogsvkprokuea"
  echo "("
  echo "tmp=\$(mktemp '${target}.XXXXXXXX')"
  echo "cat > \$tmp <<'EOF-$rnd'"
  if test -n "$file"; then
    cat "$file"
  else
    cat
  fi
  echo "EOF-$rnd"
  echo "cmp -s $2 \$tmp && rm -f \$tmp || mv \$tmp '$target'"
  echo ")"
}

remote_run <<EOF-kcskoigmtfnpttxjcjiupfgccqkpthqg
#!/bin/sh
$(put_file)
EOF-kcskoigmtfnpttxjcjiupfgccqkpthqg
