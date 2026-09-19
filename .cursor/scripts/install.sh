#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/bin:/usr/share/dotnet:${HOME}/.dotnet:${PATH}"

npm ci --prefix apps/web --no-audit --no-fund
dotnet restore apps/api/Api.sln
