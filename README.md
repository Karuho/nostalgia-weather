# Nostalgia Weather

A lightweight Windows 7-inspired weather widget for KDE Plasma 6.

Nostalgia Weather brings a resizable weather gadget to the Plasma desktop with optional native System Tray integration.

## Features

- Current weather and temperature
- 3, 5, 7, 10 or 16-day forecast
- Resizable desktop widget
- Native Plasma System Tray integration
- Current-location detection using Qt Positioning and GeoClue
- Manual worldwide location search
- Automatic IANA time-zone detection
- Celsius and Fahrenheit
- Precipitation probability
- UV index
- Sunrise and sunset
- Air quality
- Atmospheric dust
- Moon phase
- Manual refresh
- Configurable update interval
- Multiple interface languages
- No API key required
- No background daemon
- No database
- No telemetry

## Requirements

- KDE Plasma 6
- Qt 6
- Internet connection

For current-location support on Debian 13 / Trixie:

    sudo apt install qml6-module-qtpositioning libqt6positioning6-plugins

Other distributions may use different package names for Qt Positioning and GeoClue support.

## Install from GitHub

Clone the repository:

    git clone https://github.com/Karuho/nostalgia-weather.git
    cd nostalgia-weather

Install or update the widget:

    ./scripts/install-local.sh

No root privileges are required.

The widget is installed for the current user under:

    ~/.local/share/plasma/plasmoids/io.github.karuho.nostalgiaweather

## Add to the desktop

1. Right-click the Plasma desktop.
2. Enter Edit Mode.
3. Choose Add Widgets.
4. Search for Nostalgia Weather.
5. Drag it onto the desktop.

The desktop widget can be resized normally.

## Add to the System Tray

1. Right-click the Plasma System Tray.
2. Open Configure System Tray.
3. Open Entries.
4. Find Nostalgia Weather.
5. Set it to Always Shown or your preferred visibility mode.

If you want the native System Tray representation, do not add Nostalgia Weather directly to the panel through Add Widgets.

## Configuration

Open the widget settings to configure:

- Location
- Current-location detection
- Time zone
- Forecast length
- Celsius or Fahrenheit
- Update interval
- Interface language
- Visible weather information

Current-location detection is optional and runs only when explicitly requested by the user.

## Update

From the cloned repository:

    cd nostalgia-weather
    git pull --ff-only origin main
    ./scripts/install-local.sh

## Remove

Remove the installed widget:

    kpackagetool6 --type Plasma/Applet --remove io.github.karuho.nostalgiaweather

Refresh Plasma's service cache if necessary:

    kbuildsycoca6 --noincremental

## Development

Test the normal window representation:

    plasmawindowed io.github.karuho.nostalgiaweather

Test the System Tray representation:

    plasmawindowed --statusnotifier io.github.karuho.nostalgiaweather

Test with Plasma SDK:

    plasmoidviewer -a package -l floating -f planar -s 560x420

## Weather and location data

Weather and forecast data are provided by Open-Meteo.

Location search uses the Open-Meteo Geocoding API.

Current-location reverse geocoding is provided by Photon using OpenStreetMap data.

OpenStreetMap data is © OpenStreetMap contributors.

## Privacy

Nostalgia Weather has no telemetry and stores no weather history.

Current-location detection is performed only when the user explicitly requests it from the settings page.

No continuous location tracking is used.

## Project

Source code:

https://github.com/Karuho/nostalgia-weather

Issues and bug reports:

https://github.com/Karuho/nostalgia-weather/issues

## License

MIT

Copyright © 2026 DynaDev
