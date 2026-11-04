# Sourced by run_host.sh. If the worker has no ansible-playbook (image patch not applied), build a pinned venv once,
# shared by the parallel host runs and reused by later builds; its name carries a hash of the requirements.
# Needs python >= 3.10 and access to PyPI and Ansible Galaxy. Env: SUMAFORM_ANSIBLE_VENV, BOOTSTRAP_PYTHON.
if ! command -v ansible-playbook >/dev/null 2>&1; then
    _req="$here/requirements.txt"
    _venv="${SUMAFORM_ANSIBLE_VENV:-${TMPDIR:-/tmp}/sumaform-ansible-venv}-$(cat "$_req" "$here/requirements.yml" | sha1sum | cut -c1-8)"
    _py="${BOOTSTRAP_PYTHON:-$(command -v python3.12 || command -v python3.11 || command -v python3.10 || command -v python3)}"
    "$_py" -c 'import sys; sys.exit(sys.version_info < (3, 10))' \
        || { echo "ansible-playbook is missing and $_py is older than 3.10: apply ansible/worker/dockerfile-snippets.patch" >&2; exit 1; }
    (
        flock 9
        if [ ! -x "$_venv/bin/ansible-playbook" ]; then
            rm -rf "$_venv"
            "$_py" -m venv "$_venv"
            "$_venv/bin/pip" install -q -r "$_req"
            "$_venv/bin/ansible-galaxy" collection install -r "$here/requirements.yml" -p "$_venv/collections"
        fi
    ) 9> "$_venv.lock"
    export PATH="$_venv/bin:$PATH" ANSIBLE_COLLECTIONS_PATH="$_venv/collections"
fi
