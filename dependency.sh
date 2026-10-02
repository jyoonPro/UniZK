#!/bin/bash

set -euo pipefail

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential ca-certificates cmake curl git

if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
        sh -s -- -y --profile minimal --default-toolchain nightly
    source "$HOME/.cargo/env"
fi

# Keep an installed nightly toolchain unchanged on subsequent setup runs.
if ! rustup run nightly rustc --version >/dev/null 2>&1; then
    rustup toolchain install nightly --profile minimal
fi
