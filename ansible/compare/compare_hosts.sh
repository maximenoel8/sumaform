#!/bin/bash
# Usage: compare_hosts.sh <outdir> <salt-env> <ansible-env> <host-key>...   e.g. nanuk apprentice suse-minion server
# Snapshots <env>-<host-key>.mgr.suse.de on both sides (read-only ssh, key $KEY), normalizes the env prefix, diffs.
set -u
out=$1 salt=$2 ans=$3; shift 3
KEY=${KEY:-$HOME/.ssh/controller_key}
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$out"
for h in "$@"; do
  for e in "$salt" "$ans"; do
    ssh_opts="-i $KEY -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    if [ "$h" = controller ]; then
      ssh $ssh_opts "root@$e-controller.mgr.suse.de" 'sh -s' < "$here/host_state.sh" 2>/dev/null
    else
      # hop through the env's controller: server and proxy authorize only the controller's key, not ours
      ssh $ssh_opts "root@$e-controller.mgr.suse.de" "ssh -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$e-$h.mgr.suse.de 'sh -s'" < "$here/host_state.sh" 2>/dev/null
    fi | sed -E "s/$salt-|$ans-/ENV-/g" > "$out/$e-$h.txt"
  done
  echo "=== $h: $(diff "$out/$salt-$h.txt" "$out/$ans-$h.txt" | grep -c '^[<>]') differing lines ($salt = <, $ans = >)"
  diff "$out/$salt-$h.txt" "$out/$ans-$h.txt" > "$out/diff-$h.txt"
done
