#!/usr/bin/env bash
set -euo pipefail

docker exec -it nix home-manager switch --flake .#docker-arm
