#!/bin/sh
set -eu

PAK_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP_ID="bling"

BIN="${PAK_DIR}/bin/bling"

if [ -x "${BIN}" ]; then
  export BLING_PAK_DIR="${PAK_DIR}"
  export BLING_LOG_DIR="${USERDATA_PATH}/../tg5040/logs"

  mkdir -p "$(dirname "${BLING_LOG_DIR}")" 2>/dev/null || true

  cd "${PAK_DIR}"
  exec "${BIN}"
else
  echo "Executable not found: ${BIN}"
  exit 0
fi
