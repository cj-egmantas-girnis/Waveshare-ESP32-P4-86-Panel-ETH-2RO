#!/usr/bin/env bash
# Stop the emulator.
pkill -f "emu/program" && echo "Emulator stopped." || echo "Emulator not running."
