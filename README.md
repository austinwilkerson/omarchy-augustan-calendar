# Omarchy Augustan Calendar

A native Omarchy shell plugin with an Augustan decimal clock, a ten-day calendar, a year progress bar, quiet day markings, and reflections for Spirit, Soul, Mind and Body days.

The calendar opens inside Omarchy. It needs no browser, web server, account, or network connection. Theme, fonts, panel borders, motion and layout direction follow the shell.

## Install

Requires Omarchy's Quickshell-based shell with `omarchy plugin` support.

```bash
omarchy plugin add https://github.com/austinwilkerson/omarchy-augustan-calendar --enable --yes
omarchy bar move io.github.austinwilkerson.augustan --section centerBegin --index 999
```

Or clone this repository and run `bash install.sh`. Its optional argument selects `centerBegin` (default, left of the regular clock), `centerEnd` (right of it), `left`, `right`, `center`, or `tray`. The plugin follows a vertical bar too. The regular clock remains centered, and its format is preserved.

The installer backs up any existing copy under `~/.local/state/omarchy/augustan-backups/` (respecting XDG paths). When replacing the original web-link prototype, a shell restart may be needed once: `omarchy restart shell`.

## Use

- **Left-click** opens the native calendar.
- **Right-click** cycles through eight display formats and saves the selection.
- **Gear** opens settings for format, day markings, quotes, and bar placement.
- **Click a day** to see its observances and, on themed days, its reflection.
- **Click the large date**, press **Home** or **Enter** to return to today.
- **Left/Right** browse months; **Up/Down** browse years.
- **Escape** leaves settings, then closes the calendar. Clicking outside also closes it.
- Settings and day cells can be reached with **Tab** and activated with **Space/Enter**.

The default bar label is `Prime 1 Petras 07:95`. Alternatives show weekday/time, weekday/time with seconds, time alone, date/week/year, numeric date/time, date/day percentage, or day percentage alone. There is no AM/PM. `07:95:45` is `79.5%` of the day (one decimal place, capped at 99.9% before midnight).

## Calendar and reflections

Nine 40-day months each contain four ten-day weeks. Thomas has five festival days, plus Leap Day when the **following Gregorian year** is leap. December 25, 2023 is Thomas 5; December 26 is Thomas 6; December 27 is Petras 1, 2024. Gregorian century exceptions apply.

The four weekly themes fall on days 1 (Spirit), 5 (Soul), 6 (Mind), and 10 (Body), repeated every ten days. Thomas 1–4 carry those four themes; Christmas and Leap Day have no weekly theme. Weeks are numbered 1–36; Thomas has no regular week number.

Two independent settings control weekly special-day markings and high holy/religious observances. A line marks a themed day; a dot marks a holy day or observance. Hover for its name or select it for details. Hiding markings does not change quote preferences.

The local quote collection mixes Scripture, writers and thinkers, with author attribution only. Quotes appear for the selected themed day; the area disappears on ordinary days. Opening always selects today. Eight initial quotes are bundled; add more in `Quotes.js`. Provenance is in [SOURCES.md](SOURCES.md).

Time follows local civil time, including daylight saving changes. A day contains 10 hours × 100 minutes × 100 seconds, so one Augustan second is 0.864 conventional seconds. Calendar arithmetic uses civil-day ordinals to prevent daylight saving date drift.

## Settings and updates

Preferences live in this widget's entry in `~/.config/omarchy/shell.json`. The built-in settings panel writes them through Omarchy's settings API. Git-installed copies can be updated with `omarchy plugin update io.github.austinwilkerson.augustan --yes`. For a copy installed by `install.sh`, pull the source and rerun that installer.

Remove it with `omarchy plugin remove io.github.austinwilkerson.augustan --yes`. The Gregorian clock is independent.

## Verify

```bash
TZ=America/Louisville node tests/calendar.cjs
TZ=UTC node tests/calendar.cjs
omarchy plugin validate .
bash -n install.sh
```

Tests cover every calendar day from 1999 through 2401, leap and century boundaries, time conversion, all display formats, month navigation, observances, quote availability, ordinary-day hiding, year progress and tooltip escaping.

For local integration, `omarchy-shell io.github.austinwilkerson.augustan.calendar status` reports panel state. The same IPC target offers `settings`, `cycleFormat`, `today`, `nextMonth`, `previousMonth`, and `selectDay <number>`. Open/close/toggle use `omarchy-shell io.github.austinwilkerson.augustan open` (or `close`/`toggle`).

MIT licensed. Quotes retain their original public-domain provenance.
