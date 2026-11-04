#!/bin/bash
# One Ansible run for one host, triggered from Terraform (local-exec).
# Env: HOST_JSON (one-element list, see inventory.py), SUMAFORM_VM_PASSWORD (optional),
#      BUILD_NUMBER (per-build dirs, as in worker/preflight.sh),
#      SUMAFORM_KEY_DIR (per-deployment keypair dir, default ./ansible-keys in the deployment dir: made once, shared by
#      all host runs of the deployment, reused on the next apply. Replaces the committed Salt controller/build_host keys).
set -eu
umask 077  # per-build and scratch dirs 0700, files 0600
here=$(cd "$(dirname "$0")" && pwd)
base="${TMPDIR:-/tmp}/ansible-build-${BUILD_NUMBER:-$$-$RANDOM}"
mkdir -p "$base/home" "$base/local" "$base/remote"
export ANSIBLE_HOME="$base/home" ANSIBLE_LOCAL_TEMP="$base/local" ANSIBLE_REMOTE_TEMP="$base/remote"
export ANSIBLE_CONFIG="$here/ansible.cfg"

export SUMAFORM_KEY_DIR="${SUMAFORM_KEY_DIR:-$PWD/ansible-keys}"
mkdir -p "$SUMAFORM_KEY_DIR"
# host runs are parallel: the first one makes the pair, the others wait on the lock and reuse it
(
  flock 9
  [ -s "$SUMAFORM_KEY_DIR/id_ed25519" ] || ssh-keygen -q -t ed25519 -N "" -C "sumaform-deployment" -f "$SUMAFORM_KEY_DIR/id_ed25519"
) 9> "$SUMAFORM_KEY_DIR/.lock"

work=$(mktemp -d "$base/host.XXXXXX")
trap 'rm -rf "$work"' EXIT
printf '%s' "$HOST_JSON" > "$work/hosts.json"
python3 "$here/inventory.py" "$work/hosts.json" "$work/inv"

name=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))[0]["name"])' "$work/hosts.json")
# one combined run: the host roles of the host are composed by site.yml (one reboot per phase boundary)
ansible-playbook -i "$work/inv/hosts.yml" --limit "$name" "$here/playbooks/site.yml"
