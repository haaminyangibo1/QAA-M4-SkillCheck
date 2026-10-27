#!/usr/bin/env bash
# Deploys the colour app to the Kubernetes cluster kubectl is pointed at.
#
# Usage:  ./k8s-deploy.sh <dockerhub-username> <image-tag>
# e.g.    ./k8s-deploy.sh myuser 7
#
# Used by Jenkins in the Deploy stage, and can be run by hand.

set -euo pipefail   # stop on the first error, unset variable or failed pipe

DOCKERHUB_USER="${1:?Usage: ./k8s-deploy.sh <dockerhub-username> <image-tag>}"
IMAGE_TAG="${2:?Usage: ./k8s-deploy.sh <dockerhub-username> <image-tag>}"

# Folder this script lives in, so it works from any directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Deploying ${DOCKERHUB_USER}/colour-*:${IMAGE_TAG}"

# Fill in the placeholders in app.yaml and hand the result straight to kubectl.
# "apply" means: make the cluster look like this file.
sed -e "s|DOCKERHUB_USER|${DOCKERHUB_USER}|g" \
    -e "s|IMAGE_TAG|${IMAGE_TAG}|g" \
    "${SCRIPT_DIR}/k8s/app.yaml" | kubectl apply -f -

# Wait until the new pods are actually running. If they never become ready,
# this fails, and so does the Jenkins build.
kubectl rollout status deployment/backend --timeout=180s
kubectl rollout status deployment/frontend --timeout=180s

echo "Done. Pods and public address:"
kubectl get pods -l 'app in (backend,frontend)'
kubectl get service frontend
