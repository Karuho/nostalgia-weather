# Nostalgia Weather

A lightweight Windows 7-inspired weather widget for KDE Plasma 6.

Nostalgia Weather brings a compact and attractive weather forecast to the
Plasma desktop and panel, inspired by the classic Windows 7 weather gadget.

## Features

- Current weather
- Current temperature
- Five-day forecast
- Resizable desktop widget
- Compact panel representation
- Manual refresh
- Configurable location
- Configurable update interval
- Open-Meteo weather data
- No API key required
- No background daemon
- No database
- No telemetry

## Requirements

- KDE Plasma 6
- Qt 6
- Internet connection

## Local installation

Run:

    ./scripts/install-local.sh

## Test

Run:

    plasmawindowed io.github.karuho.nostalgiaweather

Or, with Plasma SDK:

    plasmoidviewer -a io.github.karuho.nostalgiaweather

## Remove

Run:

    kpackagetool6 --type Plasma/Applet --remove io.github.karuho.nostalgiaweather

## Weather data

Weather data is provided by Open-Meteo.

## Project status

Early development.

## License

MIT

## Data providers

Weather and forecast data are provided by Open-Meteo.

Location search uses the Open-Meteo Geocoding API.

Current-location reverse geocoding is provided by Photon using
OpenStreetMap data.

OpenStreetMap data is © OpenStreetMap contributors.
