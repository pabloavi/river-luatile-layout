# river-luatile-layout

WORK IN PROGRESS. LOTS OF BREAKING CHANGES TO BE MADE.

Pack of river layouts using river-luatile.

## Table of Contents

- [Features](#sec-features)
- [Installation](#sec-installation)
- [Usage](#sec-usage)
  - [Functions](#sec-functions)
- [Configuration](#sec-configuration)
  - [Variables](#sec-variables)
- [Layouts](#sec-layouts)
  - [BSPWM (dwindle)](#sec-bspwm-dwindle)
  - [Centered](#sec-centered)
  - [Grid](#sec-grid)
  - [Monocle](#sec-monocle)
  - [Rivertile](#sec-rivertile)
  - [Rivertile-simple](#sec-rivertile-simple)
  - [Tabbed](#sec-tabbed)
- [TODO](#sec-todo)

## Features <a id="sec-features" name="sec-features"></a>

- [x] A lot of layouts.
- [x] Configuration file that reloads on window open/close.
- [x] Functions to be used inside mappings.
- [x] Per-monitor configuration.
- [x] Per-tag layout: remember the layout of each tag, even on restart.

## Installation <a id="sec-installation" name="sec-installation"></a>

Install [river-luatile](https://github.com/MaxVerevkin/river-luatile), and after that clone this project into its config directory (as this is only a config).

```bash
git clone https://github.com/pabloavi/river-luatile-layout.git ~/.config/river-luatile
```

## Usage <a id="sec-usage" name="sec-usage"></a>

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

### Functions <a id="sec-functions" name="sec-functions"></a>

| Function  | Description   |
|---------- | ------------- |
| `toggle_gaps()`    | Toggles gaps to standard value or 0.     |
| `switch_layout()`  | Switches to the next layout.             |
| `cycle_layout(bool)`   | Cycles through all layouts. If argument is `true`, it sets the layout to previous one; therefore, `cycle_layout()` goes to next layout.|
| `list_layouts()`   | Prints all available layouts alphabetically in `/tmp/river_layouts`.             |
| `main_count_up()`  | Increases the number of main windows.    |
| `main_count_down()`| Decreases the number of main windows.    |
| `main_ratio_up()`  | Increases the ratio of the main area.    |
| `main_ratio_down()`| Decreases the ratio of the main area.    |
| `toggle_prefer_horizontal()`| Toggles the prefer horizontal flag. When `PREFER_HORIZONTAL` is set to true, the windows try to maximize its horizontal area |

## Configuration <a id="sec-configuration" name="sec-configuration"></a>

We provide a config file, `layout.json`, which should be placed in `~/.config/river`. Below there is an example. It has a first field, `default`, which defines properties for all layouts; if one variable (or the whole field) remains unset, they will be assigned a fallback value. Additionally, there is a field for each monitor (`output`, for river). Inside it, there is a `layout` field to set its starting layout, and an `override` with a configuration per layout, whose variables will have priority with respect to `default`.

```json
{
  "default": {
    "layout": "rivertile",
    "MAIN_RATIO": 0.65,
    "INNER_GAPS": 10,
    "OUTER_GAPS": 10,
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

### Variables <a id="sec-variables" name="sec-variables"></a>

| Variable  | Description   |
|---------- | ------------- |
| `MAIN_RATIO`    | Ratio of the main area.     |
| `GAPS`  | Gaps between windows.             |
| `SMART_GAPS`   | If true, gaps are only applied when there are more than one window.             |
| `MAIN_COUNT`   | Number of main windows.             |
| `PREFER_HORIZONTAL`   | If true, the windows try to maximize its horizontal area.             |
| `OFFSET`   | Offset of the monocle layout.             |

## Layouts <a id="sec-layouts" name="sec-layouts"></a>

(Using Waybar and a modified version of One Dark Pro colorscheme, by [NvChad](https://nvchad.com/)).

### BSPWM (dwindle) <a id="sec-bspwm" name="sec-bspwm"></a>

Default             |  Reverse
:-------------------------:|:-------------------------:
![bspwm](https://github.com/pabloavi/river-luatile-layout/assets/107482263/0734cff2-2cab-4446-ba9c-718f14500f78) | ![bspwm_reverse](https://github.com/pabloavi/river-luatile-layout/assets/107482263/bcfea75c-77f6-4026-91e8-98308c8eba32)

### Centered <a id="sec-centered" name="sec-centered"></a>

Notice in the second image that the split comes first to the right side (that's what `REVERSE` does in this layout). When using more than one main (`MAIN_COUNT>1`) the horizontal/vertical flag becomes useful.

Default, 1 main             |  Reverse, 2 main, `PREFER_HORIZONTAL = true`
:-------------------------:|:-------------------------:
![centered](https://github.com/pabloavi/river-luatile-layout/assets/107482263/5d5ebd1a-ad08-4fb0-ae11-4d4413306fca) |  ![centered_2_reverse](https://github.com/pabloavi/river-luatile-layout/assets/107482263/73cf625e-b04e-444d-8223-a786917cca78)

### Grid <a id="sec-grid" name="sec-grid"></a>

In grid layout, we never let empty spaces around the screen. Therefore, the parameter `PREFER_HORIZONTAL` is provided to choose how to cover that space maximizing space of windows horizontally or vertically.

Prefer horizontal             | Prefer vertical
:-------------------------:|:-------------------------:
![grid_horizontal](https://github.com/pabloavi/river-luatile-layout/assets/107482263/e18c71ff-10a2-4b4e-a156-9f7075041466) | ![grid_vertical](https://github.com/pabloavi/river-luatile-layout/assets/107482263/c60fdc59-0769-4ebf-89eb-46af9119ebc7)

### Monocle <a id="sec-monocle" name="sec-monocle"></a>

**MADE BY [pinpox](https://gist.github.com/pinpox)**, [monocle](https://gist.github.com/pinpox/4f6aa07aacefc2731b7ad8dfb349bdaf)

Just *almost* maximized windows; notice the offset of windows top-right and the border of main window.

![monocle](https://github.com/pabloavi/river-luatile-layout/assets/107482263/581bb092-1adc-4c82-92a9-eb66e5ba1bdc)

### Rivertile <a id="sec-rivertile" name="sec-rivertile"></a>

**MADE BY [KMIJPH](https://codeberg.org/KMIJPH)**, [rivertile](https://codeberg.org/KMIJPH/dotfiles/src/branch/main/config/river-luatile/layout.lua). Slightly modified to not have empty space and to support `SMART_GAPS = true`.

The basic rivertile layout, with option to use more than one main window, and place them top/bottom and left/right.

![rivertile](https://github.com/pabloavi/river-luatile-layout/assets/107482263/fe533da4-22f7-4bc5-8779-659dd6093b63)

### Rivertile-simple <a id="sec-rivertile-simple" name="sec-rivertile-simple"></a>

**MADE BY [MaxVerevkin](https://github.com/MaxVerevkin)**, [rivertile_simple](https://github.com/MaxVerevkin/river-luatile/blob/master/layout.lua)

The default layout of `river-luatile`, with no option to use more than one main window or modify its placement.

![rivertile_simple](https://github.com/pabloavi/river-luatile-layout/assets/107482263/2c7cb6d0-779e-4434-bf50-21e2373bc2cb)

### Tabbed (although no tab) <a id="sec-tabbed" name="sec-tabbed"></a>

It can be set to keep the main window left or right. Notice that the space in left-bottom of the screen; the windows can be seen with a vertical offset. In the second image, the fourth window is selected, to see that it can be changed. A function `bring_to_front()` is provided, to move the current window to the top of its "deck".

View 1 & 2             | View 1 & 4
:-------------------------:|:-------------------------:
![tabbed](https://github.com/pabloavi/river-luatile-layout/assets/107482263/a4658dd6-d38a-41bf-95ec-917df2e12733) | ![tabbed_2](https://github.com/pabloavi/river-luatile-layout/assets/107482263/6d1b1283-5c02-44ad-b19a-3a9b4a8bf292)

## TODO <a id="sec-todo" name="sec-todo"></a>

In order of priority:

- [ ] Add support for `SMART_BORDERS`.
- [ ] Finish `README.md`.
- [ ] Add full support of `INNER_GAPS` and `OUTER_GAPS` (only remains `rivertile`).
- [ ] Improve `centered` split when there are fewer windows than `MAIN_COUNT`.
- [ ] Refactor `bspwm` layout, as it is dirty (even though it perfectly works).
- [ ] Add support for `MAIN_COUNT` in `bspwm` layout.
