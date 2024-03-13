{% if (grains.get('server_registration_code') or grains.get('proxy_registration_code') or grains.get('sles_registration_code')) and grains['os'] == 'SUSE' %}
include:
  - scc.clean
  - scc.client
  - scc.minion
  - scc.build_host
  - scc.proxy
  - scc.server

scc_refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh --force; exit 0

{% if grains.get('use_os_released_updates') | default(false, true) %}
{% if not grains['osfullname'] == 'SLE Micro' %}
update_packages_scc:
  pkg.uptodate:
    - require:
      - sls: repos
{% endif %}
{% endif %}

{% endif %}


