# Light pages (`src/pages/light/`)

## Structure: 4 rooms × up to 7 lights, all generated from templates

```
config.yaml        rooms_amount, room/light icon substitutions, one `rooms.yaml` include per room (entities + icons)
room_select.yaml   room tab bar (room_1_btn … room_4_btn), scripts switch_to_room_N, get_rooms_amount_btn
rooms.yaml         per room: includes light_select.yaml once + light.yaml 7 times (light_1 … light_7)
light_select.yaml  per room: light tab bar (<room>_lightM_btn), script get_light_amount_btn_<room>
light.yaml         ONE light page: ${widget_name}_light_page (state, brightness/saturation sliders, color arcs)
animations.yaml    transitions between light "modes" (onoff / brightness / color_temp / rgb)
light_old/         dead code, ignore
```

Naming: room prefix `room_name_N`; light widget name `room_name_N_lightM`; page id `room_name_N_lightM_light_page`; all inner ids `${widget_name}_…`.

## Where to change what

| Task | File / place |
|---|---|
| Rename/remap a light entity | `config.yaml`, the room's `light_entity_M` |
| Change a light's icon | `config.yaml`, `light_icon_M` (codepoints defined at top of `config.yaml`) |
| How many lights a room shows | `config.yaml`, room `lights_amount` (1–7) |
| How many rooms show | `config.yaml` `rooms_amount` (currently 3; room 4 is a placeholder `room4_placeholder`) |
| Room icon | `room_icon_N` at top of `config.yaml` |
| Room title shown in the light page header | `room_title` in the room's include vars (`config.yaml`); passed on via `rooms.yaml` to `light.yaml` |
| Tab labels | Tabs are icon-only (no text): room icon in `room_select.yaml`, light icon in `light_select.yaml` |
| Look of the light page | `light.yaml`, blocks listed below |
| Animation between onoff/brightness/color temp/rgb | `animations.yaml` (`${widget_name}_animate_light_<from>_to_<to>`, started by `${widget_name}_start_lights_animation`) |

Current mapping (see `config.yaml` for truth): room 1 "Virtuvė" 7 lights, room 2 "Svetainė" 2 lights (entity 2 is a `switch.*`, not a `light.*`, so it has no dimming/color), room 3 "Darbo kambarys" 2 lights. Unused `light_entity_M` slots must still be filled with a valid entity id.

## Blocks inside `light.yaml` (widget tree order, ids are `${widget_name}_…`)
- Page `…_light_page`: `on_load` waits (35 s timeout) for `…_data_loaded`, calls `…_set_widgets_to_mode` then `…_start_lights_animation`.
- Header: `…_name_label` = room title (static `room_title` from `config.yaml`, nunito_30), `…_light_name_label` = light name (HA `friendly_name` of the light, nunito_24, filled by the `…_light_name` text sensor). `…_rooms_background` is the selector backdrop.
- `…_state_background`: left info card — `…_state_icon_bg`/`…_state_icon`, `…_percentage_label`, `…_light_brightness_slider`, `…_light_saturation_slider`.
- `…_entities_background`: light selector backdrop.
- `# CIRCLE`: `…_circle_background`, gradient objects `…_color_temp_gradient_obj`, `…_hue_gradient_obj`, `…_brightness_color_obj`, `…_circle_background_secondary`.
- Arcs: `…_light_arc_state`, `…_light_arc_brightness`, `…_light_arc_color_temp`, `…_light_arc_hue`; each `on_value` updates the globals and calls `…_update_lightbulb_color` for live preview.
- Power button: `…_circle_btn_bg`, `…_circle_btn`, `…_switch_icon`.
- `# BACK`: home-icon pill (see conventions.md); goes to `home_page` and hides `room_select_widget` + `${room_prefix}_light_select_widget`.

State/capabilities come from HA: sensors for brightness, color temp, HS color (`text_sensor`s), and globals `…_supports_color_temp|hs|rgb|brightness` decide which modes the page offers.

## Selector widgets
- `room_select_widget` (room tabs): width/visibility of buttons is computed in `get_rooms_amount_btn` from `rooms_amount` (hard-coded widths for 2/3/4 rooms). Switching: `switch_to_room_1..4` hide other rooms' light selectors and call `lvgl.page.show` for light 1 of that room.
- `${room_prefix}_light_select_widget` (light tabs): `get_light_amount_btn_<room>` shows `lights_amount` buttons.
- Each light tab's `on_press` shows its page and highlights itself (`outline_opa: cover`) while setting the other 6 tabs' outline to `transp`; limit is 7 lights per room.

## Adding a 5th room (non-trivial)
Needs: a new `rooms.yaml` include in `config.yaml`, a `room_5_btn` in `room_select.yaml`, a `switch_to_room_5` script, updates to `get_rooms_amount_btn` and to every `switch_to_room_N` hide list, plus a `room_icon_5`. Rooms are hard-wired to 4 in several scripts.
