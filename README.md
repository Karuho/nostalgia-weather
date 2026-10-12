# Nostalgia Weather

A lightweight Windows 7-inspired weather widget for KDE Plasma 6.

Nostalgia Weather brings a resizable weather gadget to the Plasma desktop with optional native System Tray integration.

## Features

- Current weather and temperature
- 3, 5, 7, 10, 16 or 30-day forecast
- Responsive hourly forecast
- Resizable desktop widget
- Native Plasma System Tray integration
- Selectable visual themes:
  - Windows 7 Classic
  - Frutiger Aero
  - Rose Quartz
  - Astral Nebula
- Selectable weather provider: Automatic, Open-Meteo or MET Norway
- Automatic MET Norway fallback when Open-Meteo weather is unavailable
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
- 30-day extended outlook using Open-Meteo ensemble data (Open-Meteo provider only)

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
- Weather provider (Automatic, Open-Meteo or MET Norway)
- Visual theme
- Forecast length
- Hourly forecast toggle
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

Weather data is provided by Open-Meteo and/or MET Norway, depending on the
weather provider selected in the widget settings.

### Weather providers

**Automatic**

- Open-Meteo is the primary weather provider.
- If the primary Open-Meteo weather request fails, Nostalgia Weather falls
  back to MET Norway.
- An air-quality failure alone does not trigger the fallback.

**Open-Meteo**

- Uses only Open-Meteo for weather.
- Supports the widget's complete forecast range.
- Days 16-30 use Open-Meteo ensemble data.

**MET Norway**

- Uses only the MET Norway Locationforecast API for weather.
- It does not silently switch back to Open-Meteo for longer forecasts.
- Forecast length is capped to the data MET Norway actually returns.
- Locationforecast provides approximately up to 9 days ahead. Because the
  current, partially elapsed day may also be present, the interface may show
  the current date plus up to roughly 9 future dates.
- Requesting 10, 16 or 30 days therefore simply shows the available MET
  Norway dates, without empty forecast cells.

### MET Norway limitations

- Availability of some variables depends on region and forecast horizon.
- Precipitation probability may be unavailable. The widget displays "--"
  instead of inventing a percentage.
- Sunrise and sunset are not supplied by the Locationforecast endpoint used
  by Nostalgia Weather, so those values display "--:--" with MET Norway.
- UV index may be unavailable on some forecast days.
- No values are fabricated to fill in missing MET Norway data.

### Remaining Open-Meteo dependencies

Selecting MET Norway does not yet remove every Open-Meteo dependency:

- Manual location search still uses the Open-Meteo Geocoding API.
- Air quality / AQI still uses Open-Meteo.
- Atmospheric dust still uses Open-Meteo.

Users in regions where Open-Meteo is inaccessible may therefore still have
limited location search, AQI and dust functionality even while MET Norway
weather works.

### Other data sources

Current-location reverse geocoding is provided by Photon using OpenStreetMap data.

OpenStreetMap data is © OpenStreetMap contributors.

### Attribution

Weather data from MET Norway used by this project is provided under the
Creative Commons Attribution 4.0 International license (CC BY 4.0) and
MET Norway's applicable open-data terms. Data is from the Norwegian
Meteorological Institute (MET Norway).

## Privacy

Nostalgia Weather has no telemetry and stores no weather history.

Current-location detection is performed only when the user explicitly requests it from the settings page.

No continuous location tracking is used.

The MET Norway cache contains only normalized weather data plus HTTP cache
metadata. No weather history is intentionally maintained, no telemetry is
added, and selecting a weather provider does not add any tracking.

## Project

Source code:

https://github.com/Karuho/nostalgia-weather

Issues and bug reports:

https://github.com/Karuho/nostalgia-weather/issues

## License

MIT

Copyright © 2026 DynaDev

### Extended forecast

With the Open-Meteo provider, forecasts beyond the short-range forecast
horizon use Open-Meteo ensemble data. Long-range outlooks have inherently greater uncertainty and should be
treated as general guidance rather than precise daily predictions.
