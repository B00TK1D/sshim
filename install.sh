#!/bin/sh

wget -O /etc/ssh/sshd_config "https://raw.githubusercontent.com/B00TK1D/sshim/main/sshd_config"
wget -O /usr/local/bin/sshim.sh "https://raw.githubusercontent.com/B00TK1D/sshim/main/sshim.sh"

chmod +x /usr/local/bin/sshim.sh
mkdir -p /etc/sshim
touch /etc/sshim/targets

useradd -m ssh
passwd -d ssh

pkill -SIGHUP -f "sshd -[D]"

