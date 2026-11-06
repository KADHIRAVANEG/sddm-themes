# SDDM Themes

44 standalone Qt Quick login themes for SDDM, with distinct layouts and shared authentication helpers packaged inside each theme.

[Browse the showcase](https://joker-53.github.io/sddm-themes/) · [Theme gallery](docs/GALLERY.md) · [Customization](docs/CUSTOMIZATION.md) · [Development and testing](docs/TESTING.md)

## Install

Install SDDM and Python 3 first. Animated themes also require FFmpeg. The installer detects the available greeter and installs missing QML modules on Arch, Debian/Ubuntu, Fedora, and openSUSE.

```bash
git clone https://github.com/KADHIRAVANEG/sddm-themes
cd sddm-themes
./install.sh --list
sudo ./install.sh marvel
```

Without a theme ID, the installer prompts for a theme number. Use `--qt 5` or `--qt 6` to select a greeter explicitly; both require the corresponding SDDM executable. Themes use Qt 5.15 or Qt6 APIs. Qt selection through theme metadata requires an SDDM version supporting `QtVersion` (SDDM 0.21 or newer is recommended).

The installer prepares the complete package, converts animated media, sets Qt metadata, and writes configuration before replacing the installed theme. Existing themes and `/etc/sddm.conf` are backed up. A preparation failure leaves the active package unchanged; a configuration publication failure restores the old package. Other files in `/etc/sddm.conf.d` are preserved; `/etc/sddm.conf` provides the final theme setting.

The theme takes effect at the next login. **Save your work before restarting SDDM from a TTY:** restarting the display manager ends graphical sessions.

## Preview

```bash
# Preview an installed Qt6 package without changing your login session:
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/marvel

# Stage temporary packages and inspect them interactively:
./test_all.sh marvel neon-gif
# Inspect all themes:
./test_all.sh
```

Use `--qt 5` for a Qt5 greeter. Manual preview logs are retained under `build/preview-logs/`; generated GIFs and packages live in temporary directories and are removed on exit. SDDM test mode does not authenticate users or execute power actions.

Uninstalled animated themes show their shipped thumbnail in QML. The installer generates the GIF used by the installed greeter. The website plays the shipped MP4 directly.

Every design uses an account dropdown with the last logged-in user selected by default. Themes read SDDM's remembered user; SDDM handles saving it after a successful login. If that account is unavailable, the selector falls back to the saved account index or the first available account. The selection stays in sync between desktop and compact layouts.

Failed logins clear and refocus the visible password, mark the field, and show feedback styled for that design. Starting a correction clears the old error. Feedback stays clear of login and system controls. Switching layouts clears both password fields while keeping the selected account and session.

All themes include a visible sign-in control, readable input text and a separate session/power footer. Desktop compositions scale to the display; smaller screens use a compact form with full-size controls. Generate a gallery of actual QML screenshots at five resolutions with `python3 scripts/check_qml.py --qt 6 --render build/theme-layouts`, then open `build/theme-layouts/index.html`. See [testing](docs/TESTING.md) for dependencies and [layout guidance](docs/LAYOUTS.md) for design conventions.

## Installer options

```bash
./install.sh neon-gif --dry-run
sudo ./install.sh neon-gif --qt 6 --fps 12 --width 1280 --duration 15
# Prepare a package under a local root without modifying system configuration:
./install.sh marvel --qt 6 --root /tmp/sddm-staging
```

Defaults bound animation conversion to 12 FPS, a maximum width of 1280 pixels, and a 15-second loop. Smaller sources are not enlarged. `--root` skips host package installation. `--skip-deps` lets you manage dependencies yourself. The installer never restarts SDDM automatically.

## Structure

```text
themes/<id>/
  Main.qml                 Distinct theme layout
  metadata.desktop         SDDM metadata
  theme.conf               Background and accent settings
  components/              Generated copies of shared QML helpers
  assets/                  Wallpaper, thumbnail, optional font
common/                    Source of shared QML helpers
website/                   Static showcase and generated catalog.js
scripts/                   Installer, previews, media and validation tools
tests/                     Installer, QML and browser regression checks
docs/                      Gallery, customization and testing guides
theme-catalog.json         Theme IDs, categories and website media paths
install.sh                 Stable installer entry point
test_all.sh                Stable manual preview entry point
index.html                 Redirect to the showcase
```

The helpers are copied into every theme so installed packages remain self-contained. Edit their source in `common/`, then run `python3 scripts/generate.py`.

## Website

```bash
python3 -m http.server 8000
# Open http://localhost:8000/website/
```

You can also open `website/index.html` directly. Browser playback/clipboard policies vary; thumbnails and manual command copying remain available. Website greeter overlays are illustrative HTML previews, not QML screenshots.

GitHub Pages deployment runs the validation, installer, Qt5/Qt6 and browser checks before publishing a staged site containing only the website and its media.

## Author

**KADHIRAVANEG** (alias **Kadhiravan E.G.**)
- GitHub: [@KADHIRAVANEG](https://github.com/KADHIRAVANEG)

## License

MIT — see [LICENSE](LICENSE).
