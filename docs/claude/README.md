# UI map for Claude

Purpose: let you say "change block X on page Y" and land on the right file/widget without reading 2,000-line YAMLs.

| Doc | Covers |
|---|---|
| [conventions.md](conventions.md) | How any edit should be done: ids, substitutions, translations, colors/fonts/icons, validate + emulator workflow |
| [home.md](home.md) | `home_page`: status bar, weather, info, settings, mode switching, forecast, bottom buttons, circle widget |
| [light.md](light.md) | Rooms + lights pages (templated), room/light selectors, how to add/remove a room or light |
| [other-pages.md](other-pages.md) | loading, devices, alarm panel, climate, cover, fan, media player, radio, vacuum |

> Written from a survey of the code (widget ids, scripts, comments), not from running every page. Treat details as pointers: open the named block and confirm before a large edit. Update these docs when you change structure.

## Page map

```
loading (boot splash disabled; HA state shown by ha_status icon + Info page)
home_page ──┬─ Lights button ──► room_name_N_lightM_light_page  (rooms + selectors)
            │                    └─ back ► home_page
            └─ Devices button ─► devices_page ─┬─ alarm_panelN_page
                                               ├─ climate_page
                                               ├─ coverN_cover_page
                                               ├─ fanN_page
                                               ├─ media_player_page
                                               ├─ radio_page
                                               └─ vacuum_page      (every sub-page has a "BACK" bar -> home_page)
```

## File layout (what lives where)

| Path | Role |
|---|---|
| `src/main.yaml` | Hardware + package list + OTA overlay (top_layer `ota_widget`) |
| `src/emulator.yaml` | Desktop emulator entry point (same pages, hardware stubbed) |
| `src/common/substitutions.yaml` | HA entity ids for home, icon codepoints, locale/timezone |
| `src/common/{colors,fonts,images}.yaml` | All color / font / image ids (declare once, use everywhere) |
| `src/pages/<page>/` | One directory per page; see per-page docs |
| `src/translations/<lang>.yaml` | i18n keys, 10 languages, default `lt` |
| `src/services/audio.yaml` | I2S audio, mixer, media player, voice assistant (not in emulator) |
| `src/pages/light_old/` | Dead code, not included anywhere |

## Finding a block fast

Everything meaningful has an `id:`. Use `grep -n "id: <widget_id>" src/pages/<page>/*.yaml` and read ~40 lines around it. Section comments (`# CIRCLE`, `# BACK`, `# SYSTEM BUTTONS (DOWN)`) mark the big blocks; many comments are in Russian (upstream project).
