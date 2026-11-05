#!/usr/bin/env bash
set -euo pipefail
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
id=io.github.austinwilkerson.augustan
target="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$id"
section="${1:-centerBegin}"
case "$section" in centerBegin|centerEnd|left|right|center|tray) ;; *) echo 'Choose centerBegin, centerEnd, left, right, center, or tray.' >&2; exit 1;; esac
omarchy plugin validate "$source_dir"
if [[ -e "$target" && "$source_dir" != "$target" ]]; then
  backup="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/augustan-backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup"
  cp -a "$target/." "$backup/"
fi
if [[ "$source_dir" != "$target" ]]; then
  mkdir -p "$target/i18n"
  cp "$source_dir/"{Augustan.qml,Model.js,Quotes.js,PlainText.qml,SettingRow.qml,manifest.json,LICENSE} "$target/"
  cp "$source_dir/i18n/en.json" "$target/i18n/"
  # Remove the earlier web-link prototype when upgrading this plugin id.
  rm -f "$target/BarWidget.qml" "$target/Augustan-Calendar.html"
fi
omarchy-shell shell rescanPlugins
omarchy plugin enable "$id" --section "$section"
omarchy bar set "$id" placement "$section"
echo 'Omarchy Augustan Calendar installed. Click to open; right-click to cycle formats.'
