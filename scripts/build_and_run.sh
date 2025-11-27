#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Building FramerClassic with Swift Package Manager..."
swift build

echo "Launching FramerClassic..."
swift run FramerClassic
