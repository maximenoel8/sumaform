"""Seam: ansible/run_host.sh, with a stubbed ansible-playbook (via PATH)."""
import json
import os
import pathlib
import stat
import subprocess

SCRIPT = pathlib.Path(__file__).parents[1] / "run_host.sh"
HOST = {"name": "mini-1", "address": "10.0.0.5", "user": "root", "port": 22,
        "bastion": None, "roles": ["minion"], "vars": {"domain": "tf.local"}}


def run(tmp, host=HOST, rc=0):
    bindir = tmp / "bin"
    bindir.mkdir()
    stub = bindir / "ansible-playbook"
    stub.write_text(f'#!/bin/bash\necho "$@" > "{tmp}/args"\n'
                    f'echo x >> "{tmp}/calls"\n'
                    f'cp "${{2}}" "{tmp}/inv.yml"\n'
                    f'd=$(dirname "${{2}}"); stat -c %a "$d" "$d/host_vars" "$d"/host_vars/*.yml > "{tmp}/modes"\n'
                    f'exit {rc}\n')
    stub.chmod(stub.stat().st_mode | stat.S_IEXEC)
    env = {**os.environ, "PATH": f"{bindir}:{os.environ['PATH']}", "TMPDIR": str(tmp),
           "BUILD_NUMBER": "7", "HOST_JSON": json.dumps([host])}
    return subprocess.run(["bash", str(SCRIPT)], env=env, capture_output=True, text=True, cwd=tmp)


def test_one_run_with_host_role_playbook(tmp_path):
    r = run(tmp_path)
    assert r.returncode == 0, r.stderr
    args = (tmp_path / "args").read_text().split()
    assert args[args.index("--limit") + 1] == "mini-1"
    assert args[-1].endswith("playbooks/site.yml")
    assert "mini-1" in (tmp_path / "inv.yml").read_text()
    # per-build dirs, scratch inventory removed afterwards
    assert (tmp_path / "ansible-build-7" / "home").is_dir()
    assert not list((tmp_path / "ansible-build-7").glob("host.*"))


def test_deployment_keypair_made_once_and_reused(tmp_path):
    assert run(tmp_path).returncode == 0
    k = tmp_path / "ansible-keys"
    priv, pub = (k / "id_ed25519").read_text(), (k / "id_ed25519.pub").read_text()
    assert oct((k / "id_ed25519").stat().st_mode & 0o777) == "0o600" and pub.startswith("ssh-ed25519 ")
    (tmp_path / "bin" / "ansible-playbook").unlink(); (tmp_path / "bin").rmdir()
    assert run(tmp_path).returncode == 0
    assert (k / "id_ed25519").read_text() == priv


def test_scratch_dir_private(tmp_path):
    assert run(tmp_path).returncode == 0
    assert (tmp_path / "modes").read_text().split() == ["700", "700", "600"]


def test_playbook_failure_fails_the_run(tmp_path):
    assert run(tmp_path, rc=2).returncode != 0


def test_multi_role_host_is_one_run(tmp_path):
    host = {**HOST, "roles": ["minion", "controller"]}
    assert run(tmp_path, host).returncode == 0
    assert len((tmp_path / "args").read_text().splitlines()) == 1  # stub overwrites; see count below
    assert (tmp_path / "calls").read_text().count("\n") == 1


def test_missing_ansible_playbook_is_bootstrapped_once_into_a_venv(tmp_path):
    import shutil
    if shutil.which("ansible-playbook"):
        return  # a real one on PATH: nothing to bootstrap
    py = tmp_path / "fakepy"
    py.write_text('#!/bin/bash\n[ "$1" = "-c" ] && exit 0\nd="$3"\nmkdir -p "$d/bin"\n'
                  'for t in pip ansible-galaxy; do printf "#!/bin/bash\\necho $t \\"\\$@\\" >> %s/log\\n" "$d/.." > "$d/bin/$t"; done\n'
                  f'printf \'#!/bin/bash\\necho played >> {tmp_path}/played\\n\' > "$d/bin/ansible-playbook"\n'
                  'chmod +x "$d"/bin/*\n')
    py.chmod(0o755)
    env = {**os.environ, "TMPDIR": str(tmp_path), "BUILD_NUMBER": "7", "HOST_JSON": json.dumps([HOST]),
           "BOOTSTRAP_PYTHON": str(py)}
    for _ in range(2):
        r = subprocess.run(["bash", str(SCRIPT)], env=env, capture_output=True, text=True, cwd=tmp_path)
        assert r.returncode == 0, r.stderr
    assert (tmp_path / "played").read_text().count("played") == 2
    venvs = list(tmp_path.glob("sumaform-ansible-venv-*"))
    assert len([v for v in venvs if v.is_dir()]) == 1  # built once, reused by the second run
    log = (tmp_path / "log").read_text()
    assert log.count("pip") == 1 and log.count("ansible-galaxy") == 1
