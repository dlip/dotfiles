#!/usr/bin/env bash
set -euo pipefail

docker run -t -d --restart=always -p 8080:8080 -v $HOME/code:/root/code --name nix nix
