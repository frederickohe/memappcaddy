#!/usr/bin/env bash
# Bootstrap shared Docker networks for the Ymca Member App stack on the VPS.
# Run once before starting any compose stack: ./setup-networks.sh
#
# Expected sibling layout:
#   /var/www/memapp-backend
#   /var/www/memappcaddy   (this repo)
#   /var/www/memapp-web

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

create_network "memapp" "Reverse proxy + inter-service HTTP (Caddy, API, pgAdmin, Portainer)"

echo ""
echo "Deploy order:"
echo "  1. ./setup-networks.sh"
echo "  2. cd ../memapp-backend && docker compose up --build -d"
echo "  3. cd ../memappcaddy && docker compose up -d"
echo "  4. ./setup-ssl.sh       (after DNS A records point here)"
echo ""
echo "DNS A records → this server's public IP:"
echo "  ymemberapp.com           → React app (public website)"
echo "  www.ymemberapp.com       → redirect to apex"
echo "  admin.ymemberapp.com     → React app (admin dashboard)"
echo "  api.ymemberapp.com       → memapp_backend"
echo "  db.ymemberapp.com        → memapp_pgadmin"
echo "  portainer.ymemberapp.com → memapp_portainer"
