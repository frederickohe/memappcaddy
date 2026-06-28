#!/usr/bin/env bash
# One-time VPS setup so GitHub Actions (deploy user) can write to app directories.
# Run on the server as root:
#   bash /var/www/memappcaddy/scripts/setup-server-for-cicd.sh
#
# Or copy from this repo after cloning, then:
#   sudo bash setup-server-for-cicd.sh

set -euo pipefail

DEPLOY_USER="${DEPLOY_USER:-deploy}"
WWW_ROOT="${WWW_ROOT:-/var/www}"

for repo in memapp-backend memapp-web memappcaddy; do
  dir="$WWW_ROOT/$repo"
  if [[ ! -d "$dir" ]]; then
    echo "Skip missing $dir"
    continue
  fi
  chown -R "$DEPLOY_USER:$DEPLOY_USER" "$dir"
  find "$dir/scripts" -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true
  echo "Ownership set: $dir -> $DEPLOY_USER"
done

# Allow deploy to manage Docker without a password (git pull + compose in CI scripts).
SUDOERS_FILE="/etc/sudoers.d/memapp-deploy"
cat > "$SUDOERS_FILE" <<EOF
$DEPLOY_USER ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose, /usr/local/bin/docker-compose
EOF
chmod 440 "$SUDOERS_FILE"
visudo -cf "$SUDOERS_FILE"

echo ""
echo "Done. Verify from your machine:"
echo "  ssh deploy@62.171.136.252 'touch /var/www/memapp-web/dist/.cicd-test && rm /var/www/memapp-web/dist/.cicd-test'"
echo "Then re-run failed GitHub Actions workflows or push to main."
