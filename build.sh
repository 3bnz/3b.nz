#!/usr/bin/env bash
set -euo pipefail
curl -sLo zola.tar.gz \
"https://github.com/getzola/zola/releases/download/v0.22.1/zola-v0.22.1-x86_64-unknown-linux-gnu.tar.gz"
tar -xf zola.tar.gz
./zola build
