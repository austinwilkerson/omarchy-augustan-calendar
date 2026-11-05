#!/usr/bin/env bash
# Optional native panel check in a running Omarchy session. No settings writes.
set -euo pipefail
plugin_dir="$(cd -- "$(dirname -- "$0")/.." && pwd)"
check_dir="$(mktemp -d)"
trap 'rm -rf -- "$check_dir"' EXIT
shell_dir="${OMARCHY_PATH:-/usr/share/omarchy}/shell"
ln -s "$shell_dir/Commons" "$check_dir/Commons"
ln -s "$shell_dir/Ui" "$check_dir/Ui"
mkdir "$check_dir/Plugin"
cp "$plugin_dir/"{Augustan.qml,Model.js,Quotes.js,PlainText.qml,SettingRow.qml} "$check_dir/Plugin/"
cp -r "$plugin_dir/i18n" "$check_dir/Plugin/"
# Expose the real lazy panel in the fixture copy only.
sed -i '/id: root/a\    property alias testPanel: panel' "$check_dir/Plugin/Augustan.qml"
cat > "$check_dir/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons as Commons
import "Plugin" as Plugin

ShellRoot {
    Plugin.Augustan { id: calendar; manageIpc: false }
    Plugin.PlainText { id: label; text: '<img src="https://example.invalid/test">' }
    Plugin.SettingRow { id: row; label: "Theme check"; width: 300 }
    Timer {
        interval: 600; running: true
        onTriggered: {
            calendar.now = new Date(2026, 0, 1, 12)
            calendar.goToToday()
            calendar.viewYear = 2023
            calendar.viewMonth = 9
            calendar.selectedDay = 6
            calendar.moveMonth(1)
            if (calendar.viewYear !== 2024 || calendar.viewMonth !== 0 || calendar.selectedDay !== 6)
                throw new Error("Festival navigation failed")
            calendar.open()
            if (!calendar.opened || calendar.editing || calendar.selectedDay !== calendar.today.day)
                throw new Error("Open did not select today")
            calendar.editing = true
            var palette = Object.assign({}, Commons.Color.shellValues)
            palette["popups.text"] = "#123456"
            Commons.Color.shellValues = palette
            Qt.callLater(function() {
                if (String(calendar.fg) !== "#123456" || String(label.color) !== "#123456")
                    throw new Error("Popup theme binding failed")
                if (label.textFormat !== Text.PlainText) throw new Error("Markup interpreted")
                finish.start()
            })
        }
    }
    Timer {
        id: finish; interval: 300
        onTriggered: {
            if (!calendar.testPanel.loadedContent || calendar.testPanel.loadedContentHeight <= 0)
                throw new Error("Lazy calendar content did not load")
            calendar.editing = false
            calendar.close()
            if (calendar.opened) throw new Error("Close failed")
            console.log("AUGUSTAN_PANEL_THEME_AND_NAVIGATION_OK")
            Qt.quit()
        }
    }
}
QML
timeout 15 quickshell -p "$check_dir" --no-duplicate > "$check_dir/check.log" 2>&1
cat "$check_dir/check.log"
rg -q 'AUGUSTAN_PANEL_THEME_AND_NAVIGATION_OK' "$check_dir/check.log"
if rg -q 'TypeError|ReferenceError|Unable to assign|Failed to load configuration|Error:' "$check_dir/check.log"; then
    exit 1
fi
