# SDDM Themes — cozylock

For Reference visit the web [grub-themes]( https://kadhiravaneg.github.io/sddm-themes/)


Ten self-contained SDDM (Qt5) themes, each built around one of the
reference wallpapers with a **deliberately different layout structure** —
no shared components, no copy-paste UI. Pick the one you want and install it.

| ID            | Vibe                             | Layout                                                    |
| ------------- | -------------------------------- | --------------------------------------------------------- |
| `marvel`      | Cinematic title card             | Tiny logo top → huge red `ENTER` block → underline inputs |
| `classic-jdm` | JDM dashboard                    | Full-bleed photo + bottom HUD bar (clock · login · power) |
| `alienx`      | Sci-fi command terminal          | Subject right, vertical green console left + scanlines    |
| `drag-racer`  | Racing telemetry HUD             | Top-left mega clock, bottom-right pill login + GO button  |
| `gojo`        | Manga monochrome split           | Left-pinned `INFINITY` panel, Gojo face stays clear right |
| `kawaii`      | Pastel rounded card              | Subject right, big rounded pink card + floating hearts    |
| `joker`       | Off-center theatrical serif      | Vignette portrait, narrow right-third login column        |
| `rdr2`        | Wanted-poster western            | Bottom-center parchment card, framed clock top-right      |
| `deadpool`    | Snarky chat-bubble panel         | Left chat-bubble login, hero portrait stays right         |
| `bmw`         | BMW M-stripe ignition HUD        | Left key-fob ignition panel, classic cars stay right      |

## Install

```bash
sudo ./install.sh marvel        # or any other theme id above
systemctl restart sddm          # or reboot
```

The script copies the chosen theme to `/usr/share/sddm/themes/<id>` and sets
`Current=<id>` in `/etc/sddm.conf`.

## Preview without rebooting

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/marvel
```

## Showcase website

A standalone static showcase lives in [`website/`](https://kadhiravaneg.github.io/sddm-themes/) — plain
HTML / CSS / JS, zero build step. Open it directly:

```bash
xdg-open website/index.html
# or serve it locally
cd website && python3 -m http.server 8000
```

The page lets you browse all ten themes, swap the live preview, copy the
install command for the active theme, and read the three-command setup —
all without leaving the `sddm-themes/` folder.

```
sddm-themes/
├── README.md
├── install.sh
├── website/                ← HTML / CSS / JS showcase
│   ├── index.html
│   ├── styles.css
│   └── script.js
├── marvel/  classic-jdm/  alienx/  drag-racer/  gojo/
├── kawaii/  joker/  rdr2/  deadpool/  bmw/
└── <each theme>/
    ├── Main.qml
    ├── metadata.desktop
    ├── theme.conf
    └── assets/wallpaper.{jpg,png}
```

## Customize

Each theme has its own `theme.conf` with a `brand` accent and `background`
path. Drop in a different wallpaper at `<theme>/assets/wallpaper.*` and
reinstall.

## Requirements

- SDDM ≥ 0.19
- Qt 5 (`qt5-quickcontrols2`, `qt5-graphicaleffects`)
- For Qt 6 systems: swap the `import QtQuick 2.15` lines for `import QtQuick`
  and set `QtVersion=6` in `metadata.desktop`.

> Heads up: SDDM is a Linux display-manager runtime — these themes can only
> be previewed on a real Linux machine with SDDM/Qt installed. The greeters
> themselves will not render inside a web browser; the `website/` page only
> showcases their wallpapers and metadata.
