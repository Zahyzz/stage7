#!/bin/bash
# Pull the latest code and images, then restart the application with Docker Compose.
# Run on the VM as azureuser (the GitHub Actions deploy job calls it via az vm run-command).
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

GIT_SSH_COMMAND='ssh -i /home/azureuser/.ssh/stage7_deploy_key -o IdentitiesOnly=yes' git pull --ff-only

docker compose pull
docker compose up -d --remove-orphans
docker image prune -f
