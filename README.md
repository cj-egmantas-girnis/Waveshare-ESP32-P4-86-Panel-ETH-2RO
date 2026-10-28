# LVGL ESPhome Waveshare-ESP32-P4-86-Panel-ETH-2RO custom firmware

<p align="center">
 <img width="200px" src="/docs/images/loading.png">
 <img width="200px" src="/docs/images/home.png">
 <img width="200px" src="/docs/images/forecasts.png">
 <img width="200px" src="/docs/images/info.png">
 <img width="200px" src="/docs/images/settings.png">
 <img width="200px" src="/docs/images/light0.png">
 <img width="200px" src="/docs/images/light1.png">
 <img width="200px" src="/docs/images/climate0.png">
 <img width="200px" src="/docs/images/climate1.png">
 <img width="200px" src="/docs/images/climate2.png">
 <img width="200px" src="/docs/images/climate3.png">
 <img width="200px" src="/docs/images/media_player.png">
 <img width="200px" src="/docs/images/vacuum.png">
</p>

<p align="center">
    <img alt="Static Badge" src="https://img.shields.io/badge/made%20by-alaltitov-blue">
    <img alt="Static Badge" src="https://img.shields.io/badge/version-v1.0%20Dev-green">
    <img alt="Static Badge" src="https://img.shields.io/badge/esphome min version-2025.11.0-red">
    <img alt="Static Badge" src="https://img.shields.io/badge/license-MIT-orange">
</p>

## Support the Project

<img src="/docs/images/donate.png" alt="QR Code" width="150" align="left" hspace="10"/>

<div style="padding-top: 40px;">
  <b>Support me on</b>
  <div style="height: 30px;"></div>
  <a href="https://boosty.to/altitov/donate">
    <img src="/docs/images/boosty.png" alt="Boosty" width="160"/>
  </a>
</div>

<br clear="all"/>

## Questions, Discussions, Ideas

<div style="padding-top: 40px;">
  <a href="https://t.me/esphome_lvgl_chats">
    <img src="/docs/images/t_me_chats.jpg" alt="QR Code" width="150" align="left" hspace="10"/>
  </a>
</div>

<br clear="all"/>

## ✨ Features

- Status indicators for Wi-Fi, Home Assistant API, thermostat, air conditioner, touchscreen lock, alarm panel
- Weather icons with current conditions and temperature
- Weather Forecasts daily and hourly
- Date and time
- Sensor readings from Home Assistant
- Voice Assistant (testing...)
- Lights control
- Alarm Panels control
- Climate control
- Covers control
- Fans control
- Media Player control
- Radio control (testing...)
- Vacuum control
- Settings:
  * Backlight adjustment
  * Screen timeout settings
  * Language selection:
    - ru (from [alaltitov](https://github.com/alaltitov))
    - en (from [alaltitov](https://github.com/alaltitov))
    - pl (from [reaper7](https://github.com/reaper7))
    - fr (from [lboue](https://github.com/lboue))
    - es (from Antonio)
    - nl (from [zjean](https://github.com/zjean))
    - si (from [Protoncek](https://github.com/Protoncek))
    - it (from [echopage1964](https://github.com/echopage1964))
    - de (from [MATZE-MAN](https://github.com/MATZE-MAN))

## 📦 Installation
> 📹 **Video [instruction](https://youtu.be/HYN_2hvcbes?si=JfYQH4vCuFlr8Q9r)**

<img width="400px" src="/docs/images/ha_options.png">

- You must enable the "Allow the device to perform Home Assistant actions." option in the ESPHome integration to Home Assistant to control devices.
- Install custom component for forecasts and covers for media player from [here](https://github.com/alaltitov/homeassistant-display-tools).
- Copy repository to vscode or to esphome folder of your Home Assistant. Change substitutions.yaml and config.yaml your entities in all widgets (only in substitution, in code everything will be substituted automatically).

## 🖥️ Desktop emulator

Test UI changes without flashing the panel. The same LVGL pages run as a native macOS app and render in a 720×720 SDL window; the mouse works as the touchscreen.

### One-time setup
- ESPHome venv (the repo pins **2026.3.3**; 2026.4.x breaks `substitutions: !include`):
  ```bash
  python3.13 -m venv .venv
  .venv/bin/pip install --only-binary cbor2 esphome==2026.3.3 fatfs-ng littlefs-python
  ```
- SDL2: `brew install sdl2-compat` (the script adds its `bin` to `PATH` itself).
- Add an API key to `src/secrets.yaml` (`openssl rand -base64 32`):
  ```yaml
  emulator_key: "<base64 key>"
  ```

### Run
```bash
./run-emulator.sh              # rebuild only if sources changed, then launch
./run-emulator.sh --build      # force rebuild
./run-emulator.sh --no-build   # launch the last build
```
Ctrl+C in the terminal stops it (or `pkill -f emu/program`). The first build takes a few minutes; `esphome config` validation alone takes 2–4 minutes.

### Real Home Assistant data
Register the emulator in HA like any ESPHome device:
1. Settings → Devices & Services → Add Integration → **ESPHome**
2. Host: your Mac's IP, port `6053`, encryption key = `emulator_key`
3. Device → Configure → enable **Allow the device to perform Home Assistant actions**

The emulator is named `<name>-emu`, so it can be registered next to the real panel. Pressing controls in the emulator switches real entities.

### How it works
| File | Purpose |
|---|---|
| `src/emulator.yaml` | Host-platform config: same page packages as `main.yaml`, SDL display + touchscreen, stub backlight, template stand-ins for WiFi/chip-temperature sensors |
| `src/pages/home/hardware.yaml` | ESP32-only sensors, split out of `home.yaml`; included by `main.yaml`, replaced in the emulator |
| `src/emu_components/i18n/` | Local copy of the `i18n` component with ESP32-only FreeRTOS debug lines guarded (host build has no FreeRTOS) |
| `src/emu_compat.h` | Host shims for ESP-IDF calls used in lambdas (`esp_random`) |

### Limitations
- Not emulated: audio / radio playback / voice assistant, relays, real backlight PWM and screen sleep, GT911 behaviour, PSRAM and performance limits.
- Always do a final check on the real panel before shipping.
- If you add new ESP32-only code (`esp_*`, `heap_caps_*`, FreeRTOS, `wifi_info`, ...) to a page, either guard it or add a stand-in in `emulator.yaml`, otherwise the emulator build breaks.

## 📖 Documentation
- [ESPHome LVGL 8.4](https://esphome.io/components/lvgl/)

## 🤝 Thanks for your help
- Thanks to [ZHNovell](https://github.com/ZHNovell) for financial support of the project, as well as for help with testing and ideas.
- Thanks, [сlydebarrow](https://github.com/clydebarrow), [jesserockz](https://github.com/jesserockz), [ssieb](https://github.com/ssieb) for helping me with the project!

