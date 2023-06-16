# river-luatile-layout

WORK IN PROGRESS. LOTS OF BREAKING CHANGES TO BE MADE.

Pack of river layouts using river-luatile.

## Installation

Install river-luatile, and after that clone this project into its config directory (as this is only a config).

```bash
git clone https://github.com/pabloavi/river-luatile-layout.git ~/.config/river-luatile
```

## Usage

Inside RiverWM, one may run the following commands to set the layout to luatile and start (or restart, wether it was already working) it:

```bash
killall river-luatile
riverctl spawn river-luatile
riverctl default-layout luatile
```

We provide some functions that can be used inside mappings, for example:

```bash
riverctl map normal Super+Control K send-layout-cmd luatile "main_count_up()"
riverctl map normal Super+Control H send-layout-cmd luatile "main_ratio_down()"
riverctl map normal Super SPACE send-layout-cmd luatile "cycle_layout()"
riverctl map normal Super+Shift SPACE send-layout-cmd luatile "cycle_layout(true)" # reverse
```

These are just examples, all available functions are listed in the Table below.

### Functions

| Function  | Description   |
|---------- | ------------- |
| `toggle_gaps()`    | Toggles gaps to standard value or 0.     |
| `switch_layout()`  | Switches to the next layout.             |
| `cycle_layout(bool)`   | Cycles through all layouts. If argument is `true`, it sets the layout to previous one; therefore, `cycle_layout()` goes to next layout.|
| `list_layouts()`   | Lists all available layouts.             |
| `main_count_up()`  | Increases the number of main windows.    |
| `main_count_down()`| Decreases the number of main windows.    |
| `main_ratio_up()`  | Increases the ratio of the main area.    |
| `main_ratio_down()`| Decreases the ratio of the main area.    |
| `toggle_prefer_horizontal()`| Toggles the prefer horizontal flag. When `PREFER_HORIZONTAL` is set to true, the windows try to maximize its horizontal area |

## Configuration

We provide a config file, `layout.json`, which should be placed in `~/.config/river`. Below there is an example. It has a first field, `default`, which defines properties for all layouts; if one variable (or the whole field) remains unset, they will be assigned a fallback value. Additionally, there is a field for each monitor (`output`, for river). Inside it, there is a `layout` field to set its starting layout, and an `override` with a configuration per layout, whose variables will have priority with respect to `default`.

```json
{
  "default": {
    "layout": "rivertile",
    "MAIN_RATIO": 0.65,
    "GAPS": 10,
    "SMART_GAPS": false,
    "MAIN_COUNT": 2,
    "PREFER_HORIZONTAL": true
  },
  "eDP-1": {
    "layout": "centered",
    "override": {
      "centered": {
        "MAIN_RATIO": 0.5,
        "GAPS": 10,
        "SMART_GAPS": false,
        "MAIN_COUNT": 1,
        "PREFER_HORIZONTAL": false
      },
      "monocle": {
        "OFFSET": 20
      },
      "rivertile": {
        "MAIN_COUNT": 2
      },
      "grid": {
        "PREFER_HORIZONTAL": false
      }
    }
  }
}
```

It is important to note that all variables are parsed to Lua as global variables, so they **must** be the same defined below. Furthermore, not every variable applies to every layout (even though setting it doesn't cause any issue).

### Variables

| Variable  | Description   |
|---------- | ------------- |
| `MAIN_RATIO`    | Ratio of the main area.     |
| `GAPS`  | Gaps between windows.             |
| `SMART_GAPS`   | If true, gaps are only applied when there are more than one window.             |
| `MAIN_COUNT`   | Number of main windows.             |
| `PREFER_HORIZONTAL`   | If true, the windows try to maximize its horizontal area.             |
| `OFFSET`   | Offset of the monocle layout.             |

## Layouts

<!-- Add images -->

### BSPWM (dwindle)

Default             |  Reverse
:-------------------------:|:-------------------------:
![bspwm](https://github.com/pabloavi/river-luatile-layout/assets/107482263/0734cff2-2cab-4446-ba9c-718f14500f78) | ![bspwm_reverse](https://github.com/pabloavi/river-luatile-layout/assets/107482263/bcfea75c-77f6-4026-91e8-98308c8eba32)

### Centered

Default             |  Reverse
:-------------------------:|:-------------------------:
![centered](https://github.com/pabloavi/river-luatile-layout/assets/107482263/5d5ebd1a-ad08-4fb0-ae11-4d4413306fca) |  ![centered_2_reverse](https://github.com/pabloavi/river-luatile-layout/assets/107482263/73cf625e-b04e-444d-8223-a786917cca78)

### Grid

Prefer horizontal             | Prefer vertical
:-------------------------:|:-------------------------:
![grid_horizontal](https://github.com/pabloavi/river-luatile-layout/assets/107482263/e18c71ff-10a2-4b4e-a156-9f7075041466) | ![grid_vertical](https://github.com/pabloavi/river-luatile-layout/assets/107482263/c60fdc59-0769-4ebf-89eb-46af9119ebc7)

### Monocle

<!-- Add credits -->

![monocle](https://github.com/pabloavi/river-luatile-layout/assets/107482263/581bb092-1adc-4c82-92a9-eb66e5ba1bdc)

### Rivertile

<!-- Add credits -->

![rivertile](https://github.com/pabloavi/river-luatile-layout/assets/107482263/fe533da4-22f7-4bc5-8779-659dd6093b63)

### Rivertile-simple

<!-- Add credits (default of river-luatile) -->

![rivertile_simple](https://github.com/pabloavi/river-luatile-layout/assets/107482263/2c7cb6d0-779e-4434-bf50-21e2373bc2cb)

### Tabbed (although no tab)

View 1 & 2             | View 1 & 4
:-------------------------:|:-------------------------:
![tabbed](https://github.com/pabloavi/river-luatile-layout/assets/107482263/a4658dd6-d38a-41bf-95ec-917df2e12733) | ![tabbed_2](https://github.com/pabloavi/river-luatile-layout/assets/107482263/6d1b1283-5c02-44ad-b19a-3a9b4a8bf292)

## TODO

- [ ] Finish `README.md`
- [ ] Add support for `MAIN_COUNT` in `bspwm` layout.
- [x] Add reverse options for `bspwm` layout and `centered`.
- [ ] Improve `centered` split when there are less windows than `MAIN_COUNT`.
- [ ] Refactor `bspwm` layout, as it is dirty (even though it perfectly works).
- [ ] Add full support of `INNER_GAPS` and `OUTER_GAPS`.
