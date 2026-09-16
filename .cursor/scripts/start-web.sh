#!/usr/bin/env bash
set -euo pipefail

npm --prefix apps/web run dev -- --host 0.0.0.0
