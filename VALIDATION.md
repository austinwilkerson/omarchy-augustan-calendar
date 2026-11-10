# Stable 4.5 validation

Verified on 2026-11-05 with Omarchy channel `stable`, package `4.5.0-3`,
Hyprland 0.56.2 and Quickshell 0.3.2.

- Calendar tests pass in America/Louisville and UTC, round-tripping every valid
  calendar day from 1999–2401, including leap/century boundaries and decimal time.
- The isolated `bash tests/check-qml.sh` check loads the real lazy calendar and
  settings content, checks festival navigation, open/today/close behavior,
  plain-text rendering and reactive popup theme colors. It writes no settings.
- Popup text and settings now consistently use the popup palette with explicit
  Commons references. Bar label styling remains supplied by WidgetButton.
- Manifest validation and installer syntax pass. The optional installer is checked
  with temporary XDG paths and stub Omarchy commands, including existing-copy
  backup and invalid-section rejection; it does not touch the desktop in this test.

The optional installer copies only plugin files into the user plugin directory,
backs up an existing copy outside that directory, rescans/enables the plugin and
changes its placement through Omarchy commands. It requires no root access and
does not modify packaged Omarchy files. Standard Git installation does not invoke
this script. Marketplace review of that installer capability remains a separate
maintainer decision.

## Runtime state audit

| Workflow | Owner | States and transition rules |
| --- | --- | --- |
| Popup and settings | [Augustan.qml](Augustan.qml), Omarchy's Panel controller | Open starts in the calendar on Today. Gear opens settings. Escape returns to the calendar, then closes it. |
| Today and browsing | [Augustan.qml](Augustan.qml), [Model.js](Model.js) | Open, Home and Today follow the live date. Selecting a day or stepping a month captures a browsing date. Midnight updates Today and keeps the browsing date. Month navigation clamps the day to the destination month. |
| Clock and display settings | [Augustan.qml](Augustan.qml), [Model.js](Model.js) | Right-click advances the persisted display format. Second-precision formats select the faster timer. Month names, markings and quotes affect presentation without changing the selected date. |
| Bar placement | [Augustan.qml](Augustan.qml), Omarchy's bar command | Idle → moving → idle or failed. The requested preference is staged before moving because Omarchy can recreate the widget. A rejected move restores the previous preference and reports the error. |

The existing calendar status command includes `viewMode` and `placementState`
alongside the selected date and error details. The isolated QML fixture tests
date rollover in both view modes and uses a fake bar command to test placement
rejection and retry.
