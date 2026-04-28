{% set osfullname = grains['osfullname'] %}
{% set osrelease = grains['osrelease'] %}
{% set is_sles_15_7 = osfullname == 'SLES' and osrelease == '15.7' %}
{% set is_ubuntu = osfullname == 'Ubuntu' %}
{% set is_tumbleweed = osfullname == 'openSUSE Tumbleweed' %}
{% set is_supported_os = is_sles_15_7 or is_ubuntu or is_tumbleweed %}
{% if is_supported_os %}
{% set rke2_version = "v1.34.2+rke2r1" %}
{% set kubeconfig = "/etc/rancher/rke2/rke2.yaml" %}

{% set pkg_map = {
  'openSUSE Tumbleweed' : ['checkpolicy', 'policycoreutils', 'container-selinux']
} %}

{% if osfullname in pkg_map %}
install_dependencies:
  pkg.latest:
    - pkgs: {{ pkg_map.get(osfullname) }}
    - refresh: True
{% endif %}

tls-san_setup_file:
  file.managed:
    - name: /etc/rancher/rke2/config.yaml
    - contents: |
        tls-san:
          - "{{ grains.get("fqdn") }}"
        ingress-controller: traefik
        {% if is_tumbleweed %}
        selinux: true
        kubelet-arg:
          - "seccomp-default=true"
        {% endif %}
    - makedirs: True

rke2_install:
  cmd.run:
    - name: curl -sfL https://get.rke2.io | sh -
    - env:
      - INSTALL_RKE2_VERSION: "{{ rke2_version }}"
    - unless: systemctl is-active rke2-server

rke2_server_enable:
  service.enabled:
    - name: rke2-server
    - require:
      - cmd: rke2_install
      - file: tls-san_setup_file

{% if is_tumbleweed %}
rke2_selinux_install:
  pkg.installed:
    - name: rke2-selinux
{% endif %}

rke2_server_start:
  service.running:
    - name: rke2-server
    - require:
      - service: rke2_server_enable
      {% if is_tumbleweed %}
      - pkg: rke2_selinux_install
      {% endif %}

link_kubectl_rke2:
  file.symlink:
    - name: /usr/local/bin/kubectl
    - target: /var/lib/rancher/rke2/bin/kubectl
    - force: True
    - makedirs: True

link_crictl_rke2:
  file.symlink:
    - name: /usr/local/bin/crictl
    - target: /var/lib/rancher/rke2/bin/crictl
    - force: True
    - makedirs: True

link_ctr_rke2:
  file.symlink:
    - name: /usr/local/bin/ctr
    - target: /var/lib/rancher/rke2/bin/ctr
    - force: True
    - makedirs: True

variables_rke2:
  file.managed:
    - name: /etc/profile.d/rke2_vars.sh
    - contents: |
        export PATH=$PATH:/opt/rke2/bin
        export KUBECONFIG={{ kubeconfig }}


{% endif %}

