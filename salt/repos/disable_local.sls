disable_all_local_repos:
  cmd.run:
    - name: zypper mr -d --all
    - onlyif: {{ 'paygo' not in grains.get('product_version') }}
    - unless: test -x /usr/bin/zypper
