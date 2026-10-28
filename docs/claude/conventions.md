# Conventions and editing rules

## Workflow for a UI edit
1. Find the block (see README "Finding a block fast").
2. Edit only that block. Keep widget `id`s unchanged unless you also update every reference (`grep -rn "<id>" src/`).
3. `.venv/bin/esphome config src/main.yaml` (2–4 min). Never flash without an explicit request.
4. Visual check: `./run-emulator.sh` (rebuilds when sources changed). Emulator does not show audio, relays, real backlight, GT911 behaviour or performance limits.
5. If you add ESP32-only code (`esp_*`, `heap_caps_*`, FreeRTOS, `wifi_info`, `internal_temperature`) to a page, guard it or add a stand-in in `src/emulator.yaml`, otherwise the emulator build breaks. ESP32-only sensors for home live in `src/pages/home/hardware.yaml`.

## Entities: change substitutions, not page YAML
- Home weather/temperature/humidity: `src/common/substitutions.yaml` (`weather_entity`, `temperature_entity`, `humidity_entity`).
- Lights / rooms: `src/pages/light/config.yaml` (see light.md).
- Alarm, cover, fan, climate, vacuum, media player: each page's `substitutions.yaml`.
- Radio stations and radio player entity: substitutions at the top of `src/pages/radio/radio.yaml`.

## Templated pages
`light.yaml`, `alarm_panel.yaml`, `cover.yaml`, `fan.yaml` are included several times with `vars:` (`widget_name`, entity). All ids inside are prefixed `${widget_name}_...`. Editing one file changes every instance; per-instance differences must come from `vars`.

## Colors, fonts, icons, images
- Colors: ids in `src/common/colors.yaml` (e.g. `color_steel_blue`, `color_misty_blue`, `color_slate_blue_gray`, `color_black`). Panel UI is dark: black background, slate-blue panels, misty-blue text/icons.
- Fonts: `nunito_16 … nunito_126` (text), `mdi_icons_36 … 78` (Material Design Icons), `icons_24 … 90` (custom icon font). Add a new size in `src/common/fonts.yaml` first.
- Icons: codepoint substitutions in `src/common/substitutions.yaml` (`"${home_icon}"`, `"${play_icon}"`, …). Use the substitution, not a raw codepoint, in widgets.
- Images: `src/common/images.yaml` (weather, flags, radio logos, battery…), files under `src/assets/images/`.
- Screen is 720×720. Panels are typically rounded `obj`s (`radius`, `bg_color: color_slate_blue_gray`, `border_opa: transp`, `shadow_opa: transp`).

## Translations (i18n)
- Keys live in `src/translations/<lang>.yaml` (lt, en, ru, de, it, nl, pl, es, fr, si). Default locale `lt`. A new key must be added to **all 10 files**.
- Static widget text is set from lambdas: `id(i18n_translations).translate("section.key")`.
- Each page has a script that re-applies labels when the language changes (`update_home_translations`, `<widget>_update_cover_translations`, `<widget>_translations`, `update_vacuum_translations`, `<widget>_update_translations`). A new translated label needs: key in all languages + an `lvgl.label.update` in that page's script.
- Language switch: `circle_settings_widget_lang_btn` on home; `flag_icon_mapping` maps locale -> flag image.

## Navigation and back
- Page change: `lvgl.page.show: <page_id>`. Sub-pages end with a `# BACK` / `# back` bar that returns to `home_page` (light pages also hide the room/light selector widgets; check the page's own block for exact behavior).
- Selector widgets (room, light, alarm, cover, fan) are separate floating widgets shown/hidden by lambdas using the `*_amount` substitutions.

## Gotchas
- `current_mode` / `is_animating` globals gate home transitions; scripts ignore requests while an animation runs.
- Touch lock is an overlay (`lock_overlay`), not per-button `clickable` flags; see home.md.
- Home idle timeout: `lvgl.on_idle` turns off `display_backlight` and pauses LVGL; a touch resumes it (`touchscreen on_release` in `main.yaml`).
- Several pages reference demo/placeholder HA entities that don't exist in this HA (climate, fan, cover, vacuum); those pages render without live data.
