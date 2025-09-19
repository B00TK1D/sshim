#!/bin/sh


if [ -n "$GITHUB_DIR" ]; then
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) Github session initialized, loading repositories" >> /var/log/sshim/sshim.log

  ssh -T -S "$1/github.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com 2>&1 | grep -oE 'Hi [^!]+' | sed 's/Hi //' > "$DIR/username"
  REPOS_FILE="/etc/sshim/repos"
  REPO_DIR="/var/opt/sshim/"

  while IFS= read -r REPO; do
    GIT_SSH_COMMAND="ssh -S $DIR/github." git clone ssh://git@github.com/$REPO "$REPO_DIR$(echo $REPO | cut -d'/' -f2)" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $REPO : Cloned to $REPO_DIR$(echo $REPO | cut -d'/' -f2)" >> /var/log/sshim/sshim.log
    else
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $REPO : Failed to clone" >> /var/log/sshim/sshim.log
    fi
  done < "$REPOS_FILE"
else
  if [ "$#" -eq 0 ]; then
    # Check if current user is not ssh
    if [ "$(whoami)" != "ssh" ]; then
      echo "No arguments provided - usage: sshim.sh [clone | ssh] <target>"
      exit 1
    fi

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) New connection" >> /var/log/sshim/sshim.log

    # Check if SSH_AUTH_SOCK is set
    if [ -n "$SSH_AUTH_SOCK" ]; then
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) SSH_AUTH_SOCK is set to $SSH_AUTH_SOCK" >> /var/log/sshim/sshim.log
    else
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) SSH_AUTH_SOCK is not set, exiting" >> /var/log/sshim/sshim.log
    fi

    TARGETS_FILE="/etc/sshim/targets"
    DIR="/tmp/sshim/$(echo $SSH_CONNECTION | cut -d' ' -f1)"
    export DIR="$DIR/$(ls $DIR 2>/dev/null | wc -l)"
    mkdir -p "$DIR"

    while IFS= read -r TARGET; do
      ssh -f -N -M -S "$DIR/$TARGET.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$TARGET" >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $TARGET : Connected at $DIR/$TARGET.sock" >> /var/log/sshim/sshim.log
      else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $TARGET : Failed to connect" >> /var/log/sshim/sshim.log
      fi
    done < "$TARGETS_FILE"

    ssh -f -N -M -S "$DIR/github.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com >/dev/null 2>&1

    if [ $? -eq 0 ]; then
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - GitHub : Connected at $DIR/github.sock" >> /var/log/sshim/sshim.log
    else
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - GitHub : Failed to connect" >> /var/log/sshim/sshim.log
    fi

    GITHUB_DIR="$DIR" nohup $0 "$DIR" >/dev/null 2>&1 &
    exit
  else
    # Check if argv[1] == "clone"
    if [ "$1" = "clone" ]; then
      if [ -z "$2" ]; then
        echo "Usage: sshim.sh clone <repository>"
        exit 1
      fi

      # Search for master socket that can access that repo
      SOCKETS=$(find /tmp/sshim -name github.sock)
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) Attempting to clone $2 using available sockets" >> /var/log/sshim/sshim.log
      echo "Attempting to clone $2 using available sockets"
      for SOCKET in $SOCKETS; do
        GIT_SSH_COMMAND="ssh -S $SOCKET" git clone ssh://git@github.com/$2 "/var/opt/sshim/$(echo $2 | cut -d'/' -f2)" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $2 : Cloned to /var/opt/sshim/$(echo $2 | cut -d'/' -f2)" >> /var/log/sshim/sshim.log
          echo "Repository cloned to /var/opt/sshim/$(echo $2 | cut -d'/' -f2)"
          exit 0
        fi
      done
      echo "Failed to clone repository $2: no sockets were able to authenticate"
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $2 : Failed to clone" >> /var/log/sshim/sshim.log
      exit 1
    elif [ "$1" = "ssh" ]; then
      if [ -z "$2" ]; then
        echo "Usage: sshim.sh ssh <target>"
        exit 1
      fi

      # Search for master socket that can access that target
      SOCKETS=$(ls -d /tmp/sshim/*/* 2>/dev/null | grep "$2.sock")
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) Attempting to connect to $2 using available sockets" >> /var/log/sshim/sshim.log
      echo "Attempting to connect to $2 using available sockets"
      for SOCKET in $SOCKETS; do
        ssh -S "$SOCKET" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$2"
        if [ $? -eq 0 ]; then
          echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $2 : Connected using socket $SOCKET" >> /var/log/sshim/sshim.log
          exit 0
        fi
      done
      echo "Failed to connect to target $2: no sockets were able to authenticate"
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($(echo $SSH_CONNECTION | cut -d' ' -f1)) - $2 : Failed to connect" >> /var/log/sshim/sshim.log
      exit 1
    elif [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
      echo "Usage: sshim.sh [clone | ssh] <target>"
      echo "  clone <repository>   Clone a GitHub repository using available SSH agent sockets"
      echo "  ssh <target>         Connect to a target using available SSH agent sockets"
      exit 0
    else
      echo "Invalid argument: $1"
      echo "Usage: sshim.sh [clone | ssh] <target>"
      exit 1
    fi
  fi
fi
