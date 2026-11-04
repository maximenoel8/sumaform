#!/bin/sh
# Read-only snapshot of what a host looks like, names only (no file contents, no secrets). Run over ssh as root.
echo "## hostname"; hostname -f 2>&1 | head -1
echo "## packages"
if command -v rpm >/dev/null 2>&1; then rpm -qa --qf '%{NAME}\n' | LC_ALL=C sort -u; else dpkg-query -W -f '${Package}\n' | LC_ALL=C sort -u; fi
echo "## enabled units"; systemctl list-unit-files --state=enabled --no-legend --no-pager 2>/dev/null | awk '{print $1}' | LC_ALL=C sort
echo "## active services"; systemctl list-units --type=service --state=running --no-legend --no-pager 2>/dev/null | awk '{print $1}' | LC_ALL=C sort
echo "## listening tcp ports"; ss -tlnH 2>/dev/null | awk '{n=split($4,a,":"); print a[n]}' | LC_ALL=C sort -un
echo "## repositories"; (ls /etc/zypp/repos.d /etc/yum.repos.d /etc/apt/sources.list.d 2>/dev/null) | LC_ALL=C sort
echo "## ssh config drop-ins"; ls /etc/ssh/sshd_config.d 2>/dev/null | LC_ALL=C sort
echo "## authorized key comments"; awk '{print $NF}' /root/.ssh/authorized_keys 2>/dev/null | LC_ALL=C sort
echo "## mounts"; findmnt -rn -o TARGET,FSTYPE 2>/dev/null | grep -v -E '^/(proc|sys|dev|run)' | LC_ALL=C sort
echo "## selected files"; for f in /etc/hostname /etc/hosts /etc/motd /root/.bashrc /etc/venv-salt-minion /etc/salt /root/.ssh/id_ed25519.pub /etc/zypp/zypp.conf.d /etc/sysctl.d /etc/ssl/certs; do [ -e "$f" ] && echo "$f"; done
