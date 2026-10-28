# Home page (`src/pages/home/`)

Files: `home.yaml` (globals, HA sensors, widget tree `home_page`, helper scripts), `animations.yaml` (mode transition scripts), `hardware.yaml` (ESP32-only sensors; replaced in the emulator).

## Concept: one page, four modes
`home_page` is a single LVGL page that morphs between four modes held in the global `current_mode`:

| Mode | Value | Shows |
|---|---|---|
| HOME | 0 | weather summary (`weather_time_widget`), clock (`datetime_widget`), weather image, Lights/Devices buttons (`middle_home_controls`), `circle_home_widget` |
| WEATHER | 1 | `weather_widget` (state label), forecast tabs + lists (`middle_weather_controls`) |
| INFO | 2 | `info_widget` (wifi dBm, IP, MAC, ESPHome version), `circle_info_widget` (CPU temp arc) |
| SETTINGS | 3 | `settings_widget` (brightness slider, sleep-time roller), `circle_settings_widget` (language button) |

Switching: bottom buttons call `script.execute: switch_to_mode` with `target_mode`. `switch_to_mode` returns early if `is_animating`, sets `current_mode`, then runs one of 12 pairwise scripts in `animations.yaml` (`animate_<from>_to_<to>`: home↔weather, home↔info, home↔settings, weather↔info, weather↔settings, info↔settings). Each script moves/fades specific widgets with LVGL animations in lambdas.
**Adding or changing what a mode shows means editing the matching animate_* scripts (both directions)**, not only the widget tree. Adding a 5th mode needs a new script for every other mode pair.

## Blocks in `home_page` (in widget-tree order)

| Block (id) | What it is | Notes |
|---|---|---|
| `home_bg_indicators` | Top status bar | Children: `wifi_status`, `ha_status`, `lock_status`, `heating_status`, `ac_status`, `alarm_panel_status` (icon labels; colors/text updated from sensors/automations) |
| `main_widget_background` | Big top panel | Holds `weather_time_widget`, `datetime_widget`, `weather_widget`, `info_widget`, `settings_widget` and `weather_state_images` |
| `weather_time_widget` | Temperature, humidity, wind | Labels `weather_temperature_value`, `weather_humidity_value`, `weather_wind_speed_value`, `weather_wind_speed_unit`; fed by `weather_*_sensor` HA sensors |
| `datetime_widget` | Day of week, date, time | `day_of_week_value`, `date_month_value`, `time_value`; updated by script `time_update` (HA time source `sntp_time`, tz from `my_timezone`) |
| `weather_widget` | Weather state text | `weather_state_label`; translated by `update_home_translations` |
| `info_widget` | Device info rows (y = 30, 87, 144, 201, 258) | `*_info_label` + `*_info_state` for wifi signal, Home Assistant (`ha_info_state`: Connected green / Disconnected), IP, MAC, ESPHome version; rows have fixed y, a 6th row needs re-spacing |
| `settings_widget` | Brightness + sleep time | `backlight_settings_brightness_slider` (controls `display_backlight`), `backlight_settings_sleep_time_roller` (sets `display_timeout_backlight` number and `display_timeout` global) |
| `weather_state_images` | Weather icon stack | One image per condition (`weather_sunny_image`, `weather_rainy_image`, …); script `update_weather_image` shows the right one from `weather_state_sensor` |
| `middle_widget_background` | Lower panel | Contains `middle_home_controls` and `middle_weather_controls` |
| `middle_home_controls` | Lights + Devices buttons | `home_lights_btn` (-> `switch_to_room_1` + shows `room_select_widget` if rooms>=2), `home_devices_btn` (-> `lvgl.page.show: devices_page`). Icons `ceiling_lights_icon`, `dashboard_icon` |
| `middle_weather_controls` | Forecast UI | Tabs `weather_forecast_daily_btn` / `weather_forecast_hourly_btn`, lists `weather_forecast_daily` / `weather_forecast_hourly` |
| `menu_controls_background` (`# SYSTEM BUTTONS (DOWN)`) | Bottom button bar | `display_lock_btn` (touch lock, indicator `display_lock_indicator`), `backlight_brightness_off_btn` (delay 1s, backlight off, LVGL pause), `home_widget_btn`/`weather_widget_btn`/`info_widget_btn`/`settings_widget_btn` -> `switch_to_mode` 0..3 |
| `circle_widget_background` (`# CIRCLE`) | Round decoration at bottom | `circle_home_widget` (temp arc + humidity arc + values, from `home_temperature_sensor`/`home_humidity_sensor`), `circle_info_widget` (CPU temp arc), `circle_settings_widget` (language arc + `circle_settings_widget_lang_btn` + flag image) |

## Weather forecast data flow
HA custom component *Display Tools* -> `sensor.display_tools_forecasts_daily|hourly` -> `weather_forecast_*_sensor` text sensors -> scripts `parse_daily_forecasts` / `parse_hourly_forecasts` (ArduinoJson) fill the `forecast_*` global arrays (10 daily, 15 hourly) -> `update_daily_display` / `update_hourly_display` write the list widgets. Without Display Tools the lists stay empty.

## Other scripts in `home.yaml`
`update_home_translations` (relabel on language change), `display_block_buttons` (touch lock: shows/hides the `lock_overlay` and colors `lock_status`; nothing to maintain per button), `update_weather_image`, `time_update`, `parse_*`, `update_*_display`; debug helpers `log_widgets_status`, `run_random_mode_tests`, `validate_mode_state`, `test_timezone` (not needed in normal use).

## Touch lock
`display_lock_switch` is bound to `display_lock_btn` (long press on the button toggles it; hold time is the 5 s `long_press_time` from `main.yaml`). When ON, `lock_overlay` (transparent 720×720 `obj` in `lvgl.top_layer`, defined at the top of the `lvgl:` block in `home.yaml`) is shown and swallows every touch on every page. Its `on_long_press` lambda reads the touch point and toggles the switch off only when the point is inside `display_lock_btn`'s area. New widgets are blocked automatically. `lock_status` (status bar) turns red while locked.

## Globals worth knowing
`current_mode`, `is_animating`, `display_lock`, `display_timeout` (roller index, persisted), `current_language` (not persisted, starts `lt`), `my_timezone`.

## Typical edits

| Task | Where |
|---|---|
| Change which HA entity feeds weather/temp/humidity | `src/common/substitutions.yaml` |
| Add/replace a status icon | `home_bg_indicators` block; if it should react to HA state, add a sensor in `home.yaml` with `on_value -> lvgl.label.update` |
| Change a bottom button icon/behaviour | `menu_controls_background` block |
| Change Lights/Devices buttons | `middle_home_controls` block |
| Add a field to Info | new `*_info_label`/`*_info_state` pair in `info_widget`; set value from a sensor, add label key to translations + `update_home_translations` |
| Change sleep-time options | roller options + `backlight_time[]` array inside the roller `on_value` (settings_widget) + `sleep_time.*` translation keys |
| Change animation look | the specific `animate_*` script in `animations.yaml` |
