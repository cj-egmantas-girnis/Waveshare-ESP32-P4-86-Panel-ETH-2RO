# Other pages

All sub-pages follow the same look: black page, slate-blue panels, a `# CIRCLE` area at the bottom with the main action, and a `# BACK`/`# back` bar at the bottom that returns to `home_page` (light.md shows the pattern). Entities come from each page's `substitutions.yaml`.

## Loading (`src/common/pages/loading.yaml`)
- The boot splash `loading_page` (LVGL top_layer; `boot_homeassistant*`, `boot_synchronization*` widgets) is **disabled**: it is `hidden: true`, so the UI is usable immediately and never waits for Home Assistant. The widgets and the `check_boot_status` / `start_sync_animation` scripts are kept but no longer called; remove `hidden: true` and re-add `id(check_boot_status).execute();` in `on_ha_connected` to restore the splash.
- Connection state is shown by `api.on_client_connected` / `on_client_disconnected` (client name starting "Home Assistant "): the status-bar icon `ha_status` goes green when connected (steel blue when not) and the Info page row `ha_info_state` shows Connected / Disconnected. `ha_connected` global is set by `on_ha_connected`.
- **Emulator**: it behaves like the device; entity data and the green HA icon appear once the emulator is added to Home Assistant (ESPHome integration).

## Devices (`src/common/pages/devices.yaml`, `devices_page`)
Centered column panel `devices_panel` with buttons: `devices_alarm_panel_btn`, `devices_climate_btn`, `devices_cover_btn`, `devices_fan_btn`, `devices_media_player_btn`, `devices_radio_btn`, `devices_vacuum_btn`. Each button is a label (English text, hard-coded) + `lvgl.page.show` to that page's first instance. Alarm/cover/fan also reveal their selector widget when more than one instance is configured.
To add a device page: new button here, new page package in `main.yaml` `packages:`.

## Alarm panel (`src/pages/alarm_panel/`)
- `config.yaml` instantiates `alarm_panel.yaml` twice (`alarm_panel1`, `alarm_panel2`); `alarm_panels_amount` (1 or 2) in `substitutions.yaml`; per-panel entity and `pin_code_N` there too. `select.yaml` = selector between panels.
- `alarm_panel.yaml`: globals `…_supported_features`, `…_current_mode`, `…_pending_action`; HA sensor/text_sensor for state; page `${widget_name}_page` with state icon, mode buttons, PIN keypad (uses a `key_collector`); scripts `…_visibility_buttons`, `…_blink`/`…_blink_stop` (arming animation), `…_update_translations`.
- `animations.yaml`: transitions between alarm states/screens.
- Home status bar icon `alarm_panel_status` reflects it.

## Climate (`src/pages/climate/climate.yaml`, 3,900+ lines, single instance)
- Page `climate_page`; entity `climate_entity` in `substitutions.yaml`.
- Blocks (comments): `# STATE`, `# HVAC MODES` (AUTO/HEAT/COOL/HEAT_COOL/DRY/FAN/OFF buttons), `# PRESETS` (ECO/AWAY/BOOST/COMFORT/HOME/SLEEP/ACTIVITY), `# TEMPERATURE WIDGET` (big dual arcs: temperature + humidity; target labels single/dual; current temp label), `# PLUS BUTTON`, `# MINUS BUTTON`, fan-mode and swing-mode floating panels (built by `climate_build_fan_modes_panel` etc.).
- Scripts all prefixed `climate_`: `update_arc_temp_range`, `update_mode_buttons_visibility`, `update_preset_buttons_visibility`, `update_segments`, `update_active_arc_layer`, `update_adjust_buttons_color`, `update_arc_hum_range`, `update_humidity_segments`, `toggle_fan_panel`, `build_fan_modes_panel`, `send_fan_mode_to_ha`, and swing equivalents.
- Visibility of modes/presets depends on what the HA entity supports; this HA has no real climate entity, so the page is mostly empty.

## Cover (`src/pages/cover/`)
- `config.yaml` instantiates `cover.yaml` up to 4 times (`cover1..4`), `covers_amount` and entities/icons in `substitutions.yaml`, `select.yaml` = selector.
- Page `${widget_name}_cover_page`: `# ICON`, `# STATE/POSITION INFO`, `# CONTROL BUTTONS` (open/stop/close, position), `# FOOTER COVER BACKGROUND`, `# CIRCLE`, `# back`. Script `…_update_cover_translations`.
- Current substitutions point at placeholder entities (`cover.kitchen_window`, …); real HA only has `cover.garage_door_garage_door` (not wired).

## Fan (`src/pages/fan/`)
- `config.yaml` instantiates `fan.yaml` twice (`fan1`, `fan2`), `fans_amount` 1 or 2, entities in `substitutions.yaml`. `animations.yaml` for transitions.
- Page `${widget_name}_page`: `# PRESETS`, `# CIRCLE` (percentage/power), `# BACK`. Globals: `…_supported_features`, `…_current_percentage`, `…_percentage_step`, `…_is_animating`. Scripts `…_translations`, `…_update_preset_buttons_visibility`.
- Entities are demo placeholders; no real fans in HA.

## Media player (`src/pages/media_player/`)
- `media_player.yaml`, `animations.yaml`, entity `media_player_entity` and `ha_server` in `substitutions.yaml` (cover art is downloaded from `ha_server` via `online_image`).
- Page `media_player_page`: cover image, title/artist/duration slider, `# PRIMARY BUTTONS` (prev/play/next…), `# SECONDARY BUTTONS` (volume, repeat, source), `# CIRCLE`, `# back`.
- Scripts: `update_cover_script`, `update_repeat_mode_script`, `handle_repeat_press_script`, `handle_duration_slider_release_script`, `media_player_build_source_panel`, `media_player_send_source_to_ha`. Globals for repeat mode, cover url, slider position, source list.

## Radio (`src/pages/radio/radio.yaml`, 236 lines)
- Page `radio_page`. Substitutions at top of the file: `radio_mp_entity` (the panel's own media player entity), `radio_station_1`, `radio_station_2` (stream URLs).
- Widgets: station buttons `station1_btn`, `station2_btn` (select station -> `current_radio_station` 1/2, restart playback if playing), circular play/stop button `circular_button_obj` with `label_play`, decorative rings `circular_button_obj1..3`.
- Script `play_selected_station` calls `media_player.play_media` through HA with the selected URL. Playback needs the real panel's audio pipeline (`services/audio.yaml`); not available in the emulator.

## Vacuum (`src/pages/vacuum/`)
- `vacuum.yaml` + `animations.yaml`; entities (`vacuum_entity`, `battery_level_entity`, `cleaned_area_entity`) in `substitutions.yaml`.
- Page `vacuum_page`: `# battery_level`, `# cleaned area`, buttons `# STOP`, `# RETURN TO BASE`, `# LOCATE`, `# CLEAN SPOT`, `# PLAY/PAUSE`, `# BACK`. Script `update_vacuum_translations`.
- Placeholder demo entities; no vacuum in HA.
