#!/bin/sh

wget -O /etc/ssh/sshd_config "https://raw.githubusercontent.com/B00TK1D/sshim/main/sshd_config"
wget -O /usr/local/bin/sshim.sh "https://raw.githubusercontent.com/B00TK1D/sshim/main/sshim.sh"

useradd -m ssh
passwd -d ssh

chmod +x /usr/local/bin/sshim.sh
mkdir -p /etc/sshim
mkdir -p /tmp/sshim
mkdir -p /var/opt/sshim
mkdir -p /var/log/sshim
chown -R ssh:ssh /tmp/sshim
chown -R ssh:ssh /var/opt/sshim
chown -R ssh:ssh /etc/sshim
chown -R ssh:ssh /var/log/sshim
touch /etc/sshim/targets
touch /etc/sshim/repos

pkill -SIGHUP -f "sshd -[D]"

