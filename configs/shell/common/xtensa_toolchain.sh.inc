#!/usr/bin/env false

if [ "${ENABLE_XTENSA:-}" = "true" ] && [ -f "/opt/esp-idf/export.sh" ]; then
  source /opt/esp-idf/export.sh
fi
