# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ESPHome firmware for the Waveshare-ESP32-P4-86-Panel-ETH-2RO — an 86mm wall panel with Ethernet and 2 relay outputs. The panel integrates with Home Assistant and provides UI controls for lights, climate, covers, fans, alarms, media player, radio, and vacuum. Hardware: ESP32-P4 (400MHz, 32MB flash, PSRAM), 720×720 MIPI DSI display, GT911 touchscreen, I2S audio (ES8311 DAC / ES7210 ADC), WiFi + ESP32-C6 Ethernet adapter, dual relay outputs. Minimum ESPHome version: **2026.1.4**.

## Build Commands

This is a pure ESPHome project — no Makefile, npm, or test runner.

```bash
# Validate and compile
esphome compile src/main.yaml

# Compile and flash over USB
esphome upload src/main.yaml

# Compile and flash OTA (device must be online)
esphome run src/main.yaml

# View device logs
esphome logs src/main.yaml
```

Secrets go in `src/secrets.yaml` (gitignored). ESPHome build artifacts land in `src/.esphome/` (gitignored).

## Architecture

### Entry point

`src/main.yaml` — hardware pins, framework settings, and all `packages:` imports. Edit hardware-level config here. Everything else is in packages.

### Package structure

All feature modules are included via `packages:` in `main.yaml`. Two layers:

- **`src/common/`** — shared across all pages: `substitutions.yaml` (Home Assistant entity IDs, icon codepoints, global names), `colors.yaml`, `fonts.yaml`, `images.yaml`, and two common pages (`loading.yaml`, `devices.yaml`).
- **`src/pages/<feature>/`** — one directory per UI page. Typical layout inside a page directory:
  - `config.yaml` — sensor subscriptions and lambdas for this page
  - `<page>.yaml` — LVGL widget tree
  - `animations.yaml` — enter/exit animation scripts
  - `substitutions.yaml` — page-local entity ID overrides
  - `select.yaml` — room/device selector widgets (where applicable)

### Home Assistant entity wiring

All HA entity IDs are defined as substitutions in `src/common/substitutions.yaml`. Pages reference them as `${substitution_name}`. To swap the entity that a page controls, change the substitution — not the page YAML.

### LVGL UI

The display runs full-screen LVGL (720×720, little-endian byte order). The top-level mode is tracked as an integer global (0=HOME, 1=WEATHER, 2=INFO, 3=SETTINGS). Mode transitions are handled by `animations.yaml` scripts in each page. There is a top-layer OTA overlay widget defined in `main.yaml`.

### Audio / voice assistant

`src/services/audio.yaml` configures the full I2S pipeline: ES8311 DAC, ES7210 ADC, mixer, resampler, media player, and voice assistant. Audio pins and I2C addresses are defined in `main.yaml` substitutions.

### Internationalization

`src/translations/<lang>.yaml` (en, ru, de, it, nl, pl, es, fr, si). A custom ESPHome component (`github://alaltitov/esphome@dev`) provides runtime language switching. Language state is a global toggled via LVGL switches.

### Assets

- `src/assets/fonts/` — Nunito-SemiBold, Material Design Icons, icons_v2
- `src/assets/images/` — 73 PNGs (weather icons, room/device icons, flags, UI chrome)

All font and image references are declared once in `src/common/fonts.yaml` and `src/common/images.yaml`.
