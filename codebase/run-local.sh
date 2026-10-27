#!/usr/bin/env bash
# Builds both images and runs the whole app on this machine with plain Docker.
# Handy for testing before Jenkins or Kubernetes are involved.
#
# Usage:  ./run-local.sh        start it, then open http://localhost:8081
#         ./run-local.sh stop   remove the containers and network

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

stop() {
    docker rm -f frontend backend >/dev/null 2>&1 || true
    docker network rm colour-net >/dev/null 2>&1 || true
}

if [ "${1:-}" = "stop" ]; then
    stop
    echo "Stopped."
    exit 0
fi

stop   # start clean every time

docker build -t colour-backend:local "${SCRIPT_DIR}/backend"
docker build -t colour-frontend:local "${SCRIPT_DIR}/frontend"

# A shared network lets containers find each other by name.
# The backend container MUST be called "backend": nginx.conf forwards to http://backend:5000
docker network create colour-net
docker run -d --name backend  --network colour-net colour-backend:local
docker run -d --name frontend --network colour-net -p 8081:80 colour-frontend:local

echo
echo "Running. Open http://localhost:8081  or try:  curl localhost:8081/colour"
