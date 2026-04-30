# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ESPHome firmware for the Waveshare-ESP32-P4-86-Panel-ETH-2RO — an 86mm wall panel with Ethernet and 2 relay outputs. The panel integrates with Home Assistant and provides UI controls for lights, climate, covers, fans, alarms, media player, radio, and vacuum. Hardware: ESP32-P4 (400MHz, 32MB flash, PSRAM), 720×720 MIPI DSI display, GT911 touchscreen, I2S audio (ES8311 DAC / ES7210 ADC), WiFi + ESP32-C6 Ethernet adapter, dual relay outputs. Minimum ESPHome version: **2026.1.4**.

## Build Commands

This is a pure ESPHome project — no Makefile, npm, or test runner.

The venv is at `.venv/` inside the repo root. Always invoke ESPHome from it:

```bash
# Validate config only (do this after every change)
.venv/bin/esphome config src/main.yaml

# Compile without flashing
.venv/bin/esphome compile src/main.yaml

# Flash over USB (run from src/ so relative includes resolve)
cd src && ../.venv/bin/esphome upload main.yaml --device /dev/tty.usbmodem5B5E1348751

# Flash OTA (device IP 192.168.1.27)
cd src && ../.venv/bin/esphome upload main.yaml --device 192.168.1.27

# Build + flash in one step (used sparingly — see workflow note below)
cd src && ../.venv/bin/esphome run main.yaml --device /dev/tty.usbmodem5B5E1348751

# View device logs
cd src && ../.venv/bin/esphome logs main.yaml --device 192.168.1.27
```

**Workflow:** After every change, validate with `esphome config` only. Do **not** flash automatically. Wait for an explicit "flash" / "build and flash" instruction — it may come after several changes.

If the USB port `/dev/tty.usbmodem5B5E1348751` is busy, check with `lsof /dev/tty.usbmodem*` and kill the holding process before retrying.

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

`src/translations/<lang>.yaml` (lt, en, ru, de, it, nl, pl, es, fr, si). A custom ESPHome component (`github://alaltitov/esphome@dev`) provides runtime language switching via `i18n`. Default locale is **Lithuanian (`lt`)** — `default_locale: lt` in `main.yaml`.

Language state is tracked in the `current_language` global (`restore_value: no`, `initial_value: "lt"`). The LVGL language switch in `home.yaml` toggles between lt (OFF) and the secondary language en (ON) via `restore_mode: RESTORE_DEFAULT_OFF`. The `flag_icon_mapping` in `home.yaml` maps locale codes to flag images including `lt: flags_lt_img`.

### Radio page

`src/pages/radio/radio.yaml` — two stations: **RadioCentras** (`https://stream2.rc.lt/rc128.mp3`) and **M-1** (`http://stream.m-1.fm/m1/mp3`). A global `current_radio_station` (int, 1 or 2) tracks the active selection. Station selector buttons on the right of the page switch the selection and restart playback if already playing. The circular play/stop button on the left uses the `play_selected_station` script.

### ESPHome version

The venv uses **ESPHome 2026.3.3**. Do not upgrade to 2026.4.x — it has a regression where `substitutions: !include` inside package files fails with `AttributeError: 'IncludeFile' object has no attribute 'items'`. Additionally, the `fatfs-ng` and `littlefs-python` packages must be installed in the venv (not the standard `fatfs` from PyPI).

### Assets

- `src/assets/fonts/` — Nunito-SemiBold, Material Design Icons, icons_v2
- `src/assets/images/` — PNGs (weather icons, room/device icons, flags incl. `lt.png`, UI chrome, radio logos)
- `src/assets/images/radio/` — `radiocentras.png`, `m1.png`
- `src/assets/images/flags/` — includes `lt.png` (Lithuanian tricolor, generated)

All font and image references are declared once in `src/common/fonts.yaml` and `src/common/images.yaml`.
