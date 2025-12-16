#!/usr/bin/env bash
set -euo pipefail

docker run -d --restart=always -p 8080:8080 --name nix nix sleep infinity
