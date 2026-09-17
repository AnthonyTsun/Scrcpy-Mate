# Scrcpy Mate

Scrcpy Mate is a native macOS control panel for Android devices built around scrcpy and ADB.

## Features

- USB and Wi-Fi mirroring
- Android wireless debugging pairing, including QR pairing
- Audio, keyboard, mouse and DeX display controls
- Embedded two-pane Mac/Android file manager
- Drag-and-drop file and APK transfer
- Chinese and English interface
- System, light and dark appearance
- Menu bar mode and global shortcuts
- Portable packaging with bundled runtime dependencies

## Build

The main AppKit source is `work/ScrcpyMate.m`. The portable package script is
`work/bundle_portable_deps.sh`.

The distributed app includes third-party open-source components. See
`work/OPEN_SOURCE_NOTICES.txt` for notices.

## Shortcuts

- `Command-Shift-M`: show or hide the Scrcpy Mate control panel
- `Control-Option-Space`: switch the macOS input language
- `Control-Option-Command-Escape`: emergency stop and release input

