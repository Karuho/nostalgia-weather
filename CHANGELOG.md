# Changelog

## 0.4.0 - Unreleased

### Added

- Responsive hourly forecast
- Visual theme engine
- Frutiger Aero theme
- Rose Quartz theme
- Astral Nebula theme
- Selectable weather providers:
  - Automatic
  - Open-Meteo
  - MET Norway
- Automatic weather fallback from Open-Meteo to MET Norway
- MET Norway cache respecting provider HTTP cache metadata
- MET Norway attribution in configuration

### Changed

- Forecast display now caps gracefully to the active provider's actual
  available horizon
- Weather provider failures no longer make successful independent AQI data
  handling part of the main weather failure path
- Missing optional provider metrics display placeholders instead of NaN
  values

### Provider notes

- Open-Meteo supports the full Nostalgia Weather forecast range.
- MET Norway is limited to its Locationforecast horizon, approximately up to
  9 days ahead.
- The current day plus future dates may result in about 10 visible calendar
  dates.
- MET Norway precipitation probability, UV, sunrise/sunset and other fields
  may be unavailable depending on the provider data.
- AQI/dust and manual geocoding remain Open-Meteo-backed.

## 0.3.1

- Improved GeoClue current-location refinement
- Resilient reverse geocoding
- Synchronized selected location between the desktop widget and System Tray
- Fixed startup and shared-location feedback loops
