{% set runtime = grains.get('container_runtime') | default('podman', true) %}
include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - server_containerized.install_{{ runtime }}
  - server_containerized.additional_disks
  - server_containerized.install_mgradm
  - server_containerized.initial_content
  - server_containerized.rhn
  - server_containerized.large_deployment
  - server_containerized.testsuite

{% if grains.get('salt_log_level') %}

restart_salt_master:
  cmd.run:
    - name: mgrctl exec 'systemctl restart salt-api salt-master'
    - require:
        - cmd: set_salt_log_level

set_salt_log_level:
  cmd.run:
    - name: >
          mgrctl exec 'grep -q "log_level" /etc/salt/master.d/99-debug.conf && sed -i "s/log_level.*/log_level: {{ grains.get('salt_log_level') }}/" /etc/salt/master.d/99-debug.conf || echo "log_level: {{ grains.get('salt_log_level') }}" >> /etc/salt/master.d/99-debug.conf'

{% endif %}
