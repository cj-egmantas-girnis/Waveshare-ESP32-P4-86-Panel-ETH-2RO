#!/usr/bin/env bash
# Start the emulator; rebuilds only if sources changed.
exec "$(dirname "$0")/run-emulator.sh" "$@"
