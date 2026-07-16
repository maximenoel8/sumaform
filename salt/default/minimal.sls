include:
  {% if grains['hostname'] and grains['domain'] %}
  - default.hostname
  {% endif %}
  - default.network
  - default.firewall
  {% if 'build_image' not in grains.get('product_version', '') and 'paygo' not in grains.get('product_version', '') %}
  - repos
  - scc
  - default.avahi
  {% else %}
  - repos.testsuite
  {% endif %}
  - default.time
  - default.users

minimal_package_update:
{% if grains.get('transactional', False) %}
  cmd.run:
{% if grains['install_salt_bundle'] %}
    - name: transactional-update -n -c package up zypper libzypp venv-salt-minion
{% else %}
    - name: transactional-update -n -c package up zypper libzypp salt-minion
{% endif %}
{% elif grains['os_family'] == 'RedHat' and grains.get('osmajorrelease', 0) | int >= 10 %}
  {# EL10+: rpm-sequoia DEFAULT rejects some OBS signing certs during dnf transaction test; use crypto-policies LEGACY for this dnf invocation only. #}
  cmd.run:
{% if grains['install_salt_bundle'] %}
    - name: RPM_SEQUOIA_CRYPTO_POLICY=/usr/share/crypto-policies/LEGACY/rpm-sequoia.txt dnf -y upgrade venv-salt-minion
{% else %}
    - name: RPM_SEQUOIA_CRYPTO_POLICY=/usr/share/crypto-policies/LEGACY/rpm-sequoia.txt dnf -y upgrade salt-minion
{% endif %}
    - order: last
{% elif grains['os_family'] == 'Debian' and grains['install_salt_bundle'] %}
  {# WORKAROUND: the DPkg::Post-Invoke hook shipped by venv-salt-minion (venv-dpkgnotify)
     runs the bundled python mid-upgrade, before the new bundle's libpython symlinks are
     configured, so apt exits non-zero even though dpkg succeeded. Retry once: the second
     run is a no-op whose hook now succeeds; genuine failures still fail twice. #}
  cmd.run:
    - name: apt-get -y install --only-upgrade venv-salt-minion || apt-get -y install --only-upgrade venv-salt-minion
    - env:
      - DEBIAN_FRONTEND: noninteractive
    - order: last
{% else %}
  pkg.latest:
    - pkgs:
{% if grains['install_salt_bundle'] %}
      - venv-salt-minion
{% else %}
      - salt-minion
{% endif %}
{% if grains['os_family'] == 'Suse' %}
      - zypper
      - libzypp
      # WORKAROUND: avoid a segfault on old versions
      {% if '12' in grains['osrelease'] %}
      - libgio-2_0-0
      {% endif %}
{% endif %}
    - order: last
{% endif %}
