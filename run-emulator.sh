#!/usr/bin/env bash
# Launch the desktop emulator, rebuilding only if sources changed since the last build.
# Usage: ./run-emulator.sh [--build | --no-build]   (default: auto)
set -euo pipefail
cd "$(dirname "$0")"

export PATH=/usr/local/opt/sdl2-compat/bin:$PATH
ESPHOME=.venv/bin/esphome
PROGRAM=src/.esphome/build/esp32-p4-waveshare-1-emu/.pioenvs/esp32-p4-waveshare-1-emu/program

needs_build() {
  [[ -x "$PROGRAM" ]] || return 0
  # any config/asset/code file newer than the binary (ignoring build output)
  [[ -n "$(find src -path src/.esphome -prune -o -type f ! -name .DS_Store -newer "$PROGRAM" -print -quit)" ]]
}

pkill -f "emu/program" 2>/dev/null || true

case "${1:-auto}" in
  --build)    $ESPHOME compile src/emulator.yaml ;;
  --no-build) ;;
  *)          if needs_build; then
                echo "Sources changed -> building..."
                $ESPHOME compile src/emulator.yaml
              else
                echo "No changes since last build -> skipping build."
              fi ;;
esac

echo "Starting emulator (Ctrl+C to stop)..."
exec "$PROGRAM"
