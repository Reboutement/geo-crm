#!/usr/bin/env bash
# Construit l'image Frappe v15 avec crm et geo_leads, puis la pousse dans votre registre.
# A lancer sur une machine avec Docker (pas besoin que ce soit le serveur Coolify).
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/votre-organisation/geo-crm}"
TAG="${TAG:-v1}"

rm -rf frappe_docker
git clone --depth 1 https://github.com/frappe/frappe_docker
cd frappe_docker

docker build \
  --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg=FRAPPE_BRANCH=version-15 \
  --build-arg=APPS_JSON_BASE64="$(base64 -w0 ../apps.json)" \
  --file=images/layered/Containerfile \
  --tag="$IMAGE:$TAG" .

docker push "$IMAGE:$TAG"
echo "Image publiee : $IMAGE:$TAG"
