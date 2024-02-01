include:
  {% if 'build_image' not in grains.get('product_version') | default('', true) %}
  - repos
  {% endif %}
  - server_containerized.install_mgradm
  - server_containerized.initial_content
  - server_containerized.testsuite
  - server_containerized.large_deployment

rhn_symlink:
  file.symlink:
    - name: /etc/rhn
    - target: /var/lib/containers/storage/volumes/etc-rhn/_data/
    - makedirs : True
    - force: True
