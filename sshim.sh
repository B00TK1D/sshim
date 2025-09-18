TARGETS_FILE="/etc/sshim/targets"
DIR="/tmp/sshim/$(echo $SSH_CONNECTION | cut -d' ' -f1)"
mkdir -p "$DIR"
for IFS= read -r TARGET; do
  ssh -f -N -M -S "$DIR/$TARGET.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$TARGET" >/dev/null 2>&1
done < "$TARGETS_FILE"
ssh -f -N -M -S "$DIR/github.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com >/dev/null 2>&1
ssh -T -S "$DIR/github.sock" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com > "$DIR/username" 2>/dev/null
