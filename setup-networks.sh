#!/usr/bin/env bash
# Bootstrap shared Docker networks for the Swappro stack on the VPS.
# Run once before starting any compose stack: ./setup-networks.sh
#
# Expected sibling layout:
#   /var/www/swapbackend
#   /var/www/swapprocaddy   (this repo)
#   /var/www/swapsite

set -euo pipefail

create_network() {
  local name="$1"
  local description="$2"

  if docker network inspect "$name" >/dev/null 2>&1; then
    echo "Network '$name' already exists — $description"
  else
    docker network create "$name" >/dev/null
    echo "Created network '$name' — $description"
  fi
}

create_network "swappro" "Reverse proxy + inter-service HTTP (Caddy, API, pgAdmin, Portainer)"

echo ""
echo "Deploy order:"
echo "  1. ./setup-networks.sh"
echo "  2. cd ../swapbackend && docker compose up --build -d"
echo "  3. cd ../swapprocaddy && docker compose up -d"
echo "  4. ./setup-ssl.sh       (after DNS A records point here)"
echo ""
echo "DNS A records → this server's public IP:"
echo "  swappro.store           → www redirect (Caddy)"
echo "  www.swappro.store       → static site"
echo "  api.swappro.store       → swappro_backend"
echo "  db.swappro.store        → swappro_pgadmin"
echo "  portainer.swappro.store → swappro_portainer"
