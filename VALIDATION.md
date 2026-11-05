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
