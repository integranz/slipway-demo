#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/bin:/usr/share/dotnet:${HOME}/.dotnet:${PATH}"
ASPNETCORE_HTTP_PORTS=8080 dotnet run --project apps/api/src/Api --no-launch-profile
