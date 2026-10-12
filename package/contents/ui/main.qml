import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import "../code/Translations.js" as I18n

PlasmoidItem {
    id: root

    width: 420
    height: 300

    property real currentTemperature: NaN
    property real apparentTemperature: NaN
    property int currentCode: -1
    property bool currentIsDay: true

    property var forecast: []

    /* Next future forecast hours of the selected location. */
    property var hourlyForecast: []
    property string hourlyRequestKey: ""

    readonly property var today:
        forecast.length > 0 ? forecast[0] : null

    property real currentAqi: NaN
    property real currentDust: NaN
    property real currentPm25: NaN

    property bool loading: false
    property string errorText: ""

    /* Provider that supplied the data currently displayed. */
    property string activeWeatherProvider: ""

    /* Incremented by every refreshWeather(); stale callbacks are ignored. */
    property int weatherRequestSerial: 0

    /* Forecast capacity of the provider supplying the displayed data. */
    property int forecastProviderLimit: 30

    readonly property string locationName:
        plasmoid.configuration.locationName || tx(
            "Location",
            "Ubicación"
        )

    readonly property string uiLanguage:
        plasmoid.configuration.language || "en"

    readonly property string visualTheme:
        plasmoid.configuration.visualTheme || "classic"

    readonly property string weatherProvider:
        plasmoid.configuration.weatherProvider || "auto"

    readonly property string temperatureUnit:
        plasmoid.configuration.temperatureUnit
        || "celsius"

    readonly property string temperatureLongUnit:
        temperatureUnit === "fahrenheit"
        ? "°F"
        : "°C"


    readonly property string configuredLatitude:
        String(
            plasmoid.configuration.latitude
            || ""
        )

    readonly property string configuredLongitude:
        String(
            plasmoid.configuration.longitude
            || ""
        )

    readonly property string configuredTimezone:
        String(
            plasmoid.configuration.timezone
            || "auto"
        )

    readonly property int configuredForecastDays:
        Number(
            plasmoid.configuration.forecastDays
            || 7
        )

    /*
     * SHARED LOCATION PROFILE
     *
     * Every running instance (desktop, System Tray, ...) has its
     * own plasmoid.configuration. The geographic profile
     * (name, latitude, longitude, timezone) is therefore mirrored
     * through a small local settings file shared by all instances.
     */
    readonly property string configuredLocationName:
        String(
            plasmoid.configuration.locationName
            || ""
        )

    property int sharedLocationRevision: 0
    property bool applyingSharedLocation: false
    property bool sharedLocationReady: false

    Settings {
        id: sharedLocationSettings

        category: "SharedLocation"

        location:
            StandardPaths.writableLocation(
                StandardPaths.GenericConfigLocation
            )
            + "/nostalgia-weather.conf"
    }

    /*
     * MET NORWAY CACHE
     *
     * Small normalized payload plus the HTTP cache metadata
     * (Expires / Last-Modified), shared by every running instance
     * through the same settings file as the shared location.
     */
    Settings {
        id: metNorwayCacheSettings

        category: "MetNorwayCache"

        location:
            StandardPaths.writableLocation(
                StandardPaths.GenericConfigLocation
            )
            + "/nostalgia-weather.conf"
    }

    /*
     * VISUAL THEME TOKENS
     *
     * Every theme-dependent presentation value lives here.
     * "classic" (Windows 7) keeps the original literals untouched;
     * any unknown theme id falls back to it. Semantic weather
     * colors (UV, AQI, sunrise/sunset accents) are not themed.
     */
    QtObject {
        id: theme

        readonly property bool aero:
            root.visualTheme === "frutiger-aero"

        readonly property bool rose:
            root.visualTheme === "rose-quartz"

        readonly property bool astral:
            root.visualTheme === "astral-nebula"

        readonly property color cardBorder:
            aero ? "#b0ffffff"
            : rose ? "#c8ffe2f2"
            : astral ? "#a0d4ccff"
            : "#80ffffff"

        readonly property color cardGradientTop:
            aero ? "#c83aa8e8"
            : rose ? "#c8e698c8"
            : astral ? "#d03a44a8"
            : "#c05a6a78"

        readonly property color cardGradientMiddle:
            aero ? "#c81c6fc2"
            : rose ? "#c8c4409a"
            : astral ? "#d05a2cb0"
            : "#c0334352"

        readonly property color cardGradientBottom:
            aero ? "#d2158f6a"
            : rose ? "#d2764096"
            : astral ? "#e01c1a5c"
            : "#dc15232f"

        readonly property color cardTopGloss:
            aero ? "#30ffffff"
            : rose ? "#34fff0f8"
            : astral ? "#20c4ccff"
            : "#18ffffff"

        readonly property color divider:
            aero ? "#70ffffff"
            : rose ? "#78ffe6f2"
            : astral ? "#58d6ceff"
            : "#45ffffff"

        /*
         * Frutiger Aero decorative layers only. These are never
         * shown when classic is active.
         */
        readonly property color aeroSkyGlowTop:
            "#4cd8fcff"

        readonly property color aeroSkyGlowBottom:
            "#003aa8e8"

        readonly property color aeroHorizonTop:
            "#0090e8ff"

        readonly property color aeroHorizonCenter:
            "#3ac8f6ff"

        readonly property color aeroHorizonBottom:
            "#0090e8ff"

        readonly property color aeroFreshGlowTop:
            "#0030d8a8"

        readonly property color aeroFreshGlowBottom:
            "#5a58f0b8"

        readonly property color aeroSpecular:
            "#34ffffff"

        readonly property color aeroSpecularSoft:
            "#08ffffff"

        /*
         * Rose Quartz decorative layers only. Never shown unless
         * rose-quartz is active.
         */
        readonly property color roseBloomTop:
            "#52ffd6ee"

        readonly property color roseBloomBottom:
            "#00ff9ed4"

        readonly property color rosePearlTop:
            "#00fff0f8"

        readonly property color rosePearlCenter:
            "#40fff2f9"

        readonly property color rosePearlBottom:
            "#00fff0f8"

        readonly property color roseLowerGlowTop:
            "#00b890ff"

        readonly property color roseLowerGlowBottom:
            "#5ce070bc"

        readonly property color roseSpecular:
            "#3cfff6fb"

        readonly property color roseSpecularSoft:
            "#0affe6f4"

        /*
         * Astral Nebula decorative layers only. Never shown unless
         * astral-nebula is active.
         */
        readonly property color astralNebulaTop:
            "#4c7a70ff"

        readonly property color astralNebulaBottom:
            "#006a64ff"

        readonly property color astralHorizonTop:
            "#00b45cff"

        readonly property color astralHorizonCenter:
            "#40b860ff"

        readonly property color astralHorizonBottom:
            "#00b45cff"

        readonly property color astralAtmosphereTop:
            "#001a1a5c"

        readonly property color astralAtmosphereBottom:
            "#68080838"

        readonly property color astralSpecular:
            "#2ac8d2ff"

        readonly property color astralSpecularSoft:
            "#06c8d2ff"

        readonly property color astralStar:
            "#a8eef0ff"

        readonly property color astralStarDim:
            "#58c8d0ff"

        /*
         * Static star field: [x fraction, y fraction, size px,
         * bright]. Positions scale with the card; no randomness.
         */
        readonly property var astralStars: [
            [0.08, 0.10, 2, true],
            [0.22, 0.05, 1.5, false],
            [0.47, 0.13, 1.5, false],
            [0.71, 0.06, 2, true],
            [0.90, 0.16, 1.5, false],
            [0.95, 0.42, 2, true],
            [0.04, 0.55, 1.5, false],
            [0.62, 0.50, 1.5, false],
            [0.15, 0.88, 2, true],
            [0.38, 0.93, 1.5, false],
            [0.80, 0.84, 1.5, false],
            [0.93, 0.94, 2, false]
        ]

        readonly property color primaryText:
            "white"

        readonly property color secondaryText:
            aero ? "#f4ffffff"
            : rose ? "#f8fff6fb"
            : astral ? "#f4f2eeff"
            : "#e4ffffff"

        readonly property color mutedText:
            aero ? "#dcffffff"
            : rose ? "#e6ffeef7"
            : astral ? "#d8e0daff"
            : "#bfffffff"

        readonly property color dateText:
            aero ? "#f6ffffff"
            : rose ? "#fafff6fb"
            : astral ? "#f6f2eeff"
            : "#e8ffffff"

        readonly property color metricText:
            aero ? "#f8ffffff"
            : rose ? "#fafff8fc"
            : astral ? "#f8f4f0ff"
            : "#f0ffffff"

        readonly property color airMetricText:
            aero ? "#f6ffffff"
            : rose ? "#f8fff6fb"
            : astral ? "#f4f0ecff"
            : "#eaffffff"

        readonly property color dailyPrimaryText:
            aero ? "#f8ffffff"
            : rose ? "#fafff8fc"
            : astral ? "#f8f4f0ff"
            : "#efffffff"

        readonly property color dailySecondaryText:
            aero ? "#e6ffffff"
            : rose ? "#eafff0f8"
            : astral ? "#e0e6e0ff"
            : "#cfffffff"

        readonly property color hourlyPrimaryText:
            aero ? "#f8ffffff"
            : rose ? "#fafff8fc"
            : astral ? "#f8f4f0ff"
            : "#efffffff"

        readonly property color hourlySecondaryText:
            aero ? "#e6ffffff"
            : rose ? "#eafff0f8"
            : astral ? "#e0e6e0ff"
            : "#cfffffff"
    }

    function tx(en, es) {
        return I18n.t(
            uiLanguage,
            en,
            es
        )
    }

    function sharedText(value) {
        if (value === undefined || value === null)
            return ""

        if (
            typeof value === "object"
            && typeof value.join === "function"
        ) {
            return value.join(",")
        }

        return String(value)
    }

    function coordinateValue(text, limit) {
        var trimmed = sharedText(text).trim()

        if (trimmed === "")
            return NaN

        var value = Number(trimmed.replace(",", "."))

        if (!isFinite(value) || Math.abs(value) > limit)
            return NaN

        return value
    }

    /*
     * Returns a validated profile, or null when any part is invalid.
     * Coordinates keep their original string representation.
     */
    function locationProfile(name, latitude, longitude, timezone) {
        name = sharedText(name)
        timezone = sharedText(timezone)

        if (name.trim() === "" || timezone.trim() === "")
            return null

        var latitudeValue = coordinateValue(latitude, 90)
        var longitudeValue = coordinateValue(longitude, 180)

        if (isNaN(latitudeValue) || isNaN(longitudeValue))
            return null

        return {
            locationName: name,
            latitude: sharedText(latitude).trim(),
            longitude: sharedText(longitude).trim(),
            timezone: timezone,
            latitudeValue: latitudeValue,
            longitudeValue: longitudeValue
        }
    }

    function currentLocationProfile() {
        return locationProfile(
            plasmoid.configuration.locationName,
            plasmoid.configuration.latitude,
            plasmoid.configuration.longitude,
            plasmoid.configuration.timezone
        )
    }

    function storedLocationProfile() {
        return locationProfile(
            sharedLocationSettings.value("locationName", ""),
            sharedLocationSettings.value("latitude", ""),
            sharedLocationSettings.value("longitude", ""),
            sharedLocationSettings.value("timezone", "")
        )
    }

    function storedLocationRevision() {
        var revision = Math.floor(
            Number(
                sharedLocationSettings.value("revision", 0)
            )
        )

        return isFinite(revision) && revision > 0
            ? revision
            : 0
    }

    function sameLocationProfile(a, b) {
        return a.locationName === b.locationName
            && a.timezone === b.timezone
            && a.latitudeValue === b.latitudeValue
            && a.longitudeValue === b.longitudeValue
    }

    /*
     * Imports the shared profile into this instance's configuration.
     * Returns true when any configuration value was changed.
     * Existing configured*Changed handlers schedule the refresh.
     */
    function importSharedLocation() {
        var revision = storedLocationRevision()

        sharedLocationRevision = revision

        if (revision <= 0)
            return false

        var profile = storedLocationProfile()

        if (profile === null)
            return false

        var changed = false

        applyingSharedLocation = true

        try {
            if (
                sharedText(plasmoid.configuration.locationName)
                !== profile.locationName
            ) {
                plasmoid.configuration.locationName =
                    profile.locationName
                changed = true
            }

            if (
                coordinateValue(
                    plasmoid.configuration.latitude,
                    90
                ) !== profile.latitudeValue
            ) {
                plasmoid.configuration.latitude =
                    profile.latitude
                changed = true
            }

            if (
                coordinateValue(
                    plasmoid.configuration.longitude,
                    180
                ) !== profile.longitudeValue
            ) {
                plasmoid.configuration.longitude =
                    profile.longitude
                changed = true
            }

            if (
                sharedText(plasmoid.configuration.timezone)
                !== profile.timezone
            ) {
                plasmoid.configuration.timezone =
                    profile.timezone
                changed = true
            }
        } finally {
            applyingSharedLocation = false
        }

        return changed
    }

    function publishSharedLocation() {
        var profile = currentLocationProfile()

        if (profile === null)
            return

        sharedLocationSettings.sync()

        var storedRevision = storedLocationRevision()
        var stored = storedLocationProfile()

        /* Already shared: avoid a pointless write and revision bump. */
        if (
            storedRevision > 0
            && stored !== null
            && sameLocationProfile(stored, profile)
        ) {
            sharedLocationRevision = storedRevision
            return
        }

        var revision =
            Math.max(
                storedRevision,
                sharedLocationRevision
            ) + 1

        sharedLocationSettings.setValue(
            "locationName", profile.locationName
        )
        sharedLocationSettings.setValue(
            "latitude", profile.latitude
        )
        sharedLocationSettings.setValue(
            "longitude", profile.longitude
        )
        sharedLocationSettings.setValue(
            "timezone", profile.timezone
        )
        sharedLocationSettings.setValue(
            "revision", revision
        )

        sharedLocationSettings.sync()

        sharedLocationRevision = revision
    }

    function scheduleSharedLocationPublish() {
        if (!sharedLocationReady
                || applyingSharedLocation
                || !plasmoid.userConfiguring) {
            return
        }

        sharedLocationPublishTimer.restart()
    }

    function pollSharedLocation() {
        /* A local change is pending; it will supersede the file. */
        if (sharedLocationPublishTimer.running)
            return

        sharedLocationSettings.sync()

        var revision = storedLocationRevision()

        if (revision === sharedLocationRevision)
            return

        importSharedLocation()
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    /*
     * When Nostalgia Weather is enabled inside Plasma's
     * System Tray, keep its compact representation visible.
     */
    Plasmoid.status: PlasmaCore.Types.ActiveStatus

    Plasmoid.icon: weatherIcon(currentCode, currentIsDay)

    toolTipMainText: locationName

    toolTipSubText: isNaN(currentTemperature)
        ? i18n("Nostalgia Weather")
        : Math.round(currentTemperature)
          + " "
          + root.temperatureLongUnit
          + " · "
          + weatherText(currentCode)

    switchWidth: 240
    switchHeight: 165

    function weatherIcon(code, day) {
        if (code === 0)
            return day ? "weather-clear" : "weather-clear-night"

        if (code === 1 || code === 2)
            return day
                ? "weather-few-clouds"
                : "weather-few-clouds-night"

        if (code === 3)
            return "weather-clouds"

        if (code === 45 || code === 48)
            return "weather-fog"

        if (code >= 51 && code <= 57)
            return "weather-showers-scattered"

        if ((code >= 61 && code <= 67)
                || (code >= 80 && code <= 82))
            return "weather-showers"

        if ((code >= 71 && code <= 77)
                || code === 85
                || code === 86)
            return "weather-snow"

        if (code >= 95)
            return "weather-storm"

        return "weather-none-available"
    }

    function weatherText(code) {
        if (code === 0)
            return tx("Clear", "Despejado")

        if (code === 1)
            return tx("Mainly clear", "Mayormente despejado")

        if (code === 2)
            return tx("Partly cloudy", "Parcialmente nublado")

        if (code === 3)
            return tx("Cloudy", "Nublado")

        if (code === 45 || code === 48)
            return tx("Fog", "Niebla")

        if (code >= 51 && code <= 57)
            return tx("Drizzle", "Llovizna")

        if (code >= 61 && code <= 67)
            return tx("Rain", "Lluvia")

        if (code >= 71 && code <= 77)
            return tx("Snow", "Nieve")

        if (code >= 80 && code <= 82)
            return tx("Rain showers", "Chubascos")

        if (code === 85 || code === 86)
            return tx("Snow showers", "Chubascos de nieve")

        if (code >= 95)
            return tx("Thunderstorm", "Tormenta")

        return tx("No data", "Sin datos")
    }

    function localeName() {
        if (uiLanguage === "es")
            return "es_CL"

        if (uiLanguage === "pt")
            return "pt_BR"

        if (uiLanguage === "fr")
            return "fr_FR"

        if (uiLanguage === "de")
            return "de_DE"

        if (uiLanguage === "it")
            return "it_IT"

        if (uiLanguage === "ja")
            return "ja_JP"

        if (uiLanguage === "zh-CN")
            return "zh_CN"

        if (uiLanguage === "zh-TW")
            return "zh_TW"

        if (uiLanguage === "ko")
            return "ko_KR"

        if (uiLanguage === "ru")
            return "ru_RU"

        return "en_US"
    }

    function dayName(dateString) {
        var date = new Date(dateString + "T12:00:00")

        return date.toLocaleDateString(
            Qt.locale(root.localeName()),
            "ddd"
        )
    }

    function forecastDayName(dateString, index) {
        if (index === 0)
            return tx("Today", "Hoy")

        return dayName(dateString)
    }

    function shortDate(dateString) {
        var date = new Date(dateString + "T12:00:00")

        var day = date.getDate()
        var month = date.getMonth() + 1

        if (
            uiLanguage === "en"
            || uiLanguage === "ja"
            || uiLanguage === "zh-CN"
            || uiLanguage === "zh-TW"
            || uiLanguage === "ko"
        ) {
            return month + "/" + day
        }

        return day + "/" + month
    }

    function longDate(dateString) {
        var date = new Date(dateString + "T12:00:00")

        return date.toLocaleDateString(
            Qt.locale(root.localeName()),
            "ddd d MMM"
        )
    }

    function timePart(value) {
        if (!value || value.length < 16)
            return "--:--"

        return value.substring(11, 16)
    }

    function moonInfo(dateString) {
        /*
         * Aproximación suficiente para representación visual.
         * Referencia: Luna nueva 2000-01-06 18:14 UTC.
         */
        var synodicMonth = 29.53058867
        var epoch = Date.UTC(2000, 0, 6, 18, 14, 0)

        var date = new Date(dateString + "T12:00:00Z")
        var days = (date.getTime() - epoch) / 86400000.0

        var age = days % synodicMonth

        if (age < 0)
            age += synodicMonth

        var phase = age / synodicMonth

        if (phase < 0.0625 || phase >= 0.9375)
            return {
                icon: "●",
                name: tx("New moon", "Luna nueva")
            }

        if (phase < 0.1875)
            return {
                icon: "◔",
                name: tx("Waxing crescent", "Creciente")
            }

        if (phase < 0.3125)
            return {
                icon: "◑",
                name: tx("First quarter", "Cuarto creciente")
            }

        if (phase < 0.4375)
            return {
                icon: "◕",
                name: tx("Waxing gibbous", "Gibosa creciente")
            }

        if (phase < 0.5625)
            return {
                icon: "○",
                name: tx("Full moon", "Luna llena")
            }

        if (phase < 0.6875)
            return {
                icon: "◕",
                name: tx("Waning gibbous", "Gibosa menguante")
            }

        if (phase < 0.8125)
            return {
                icon: "◐",
                name: tx("Last quarter", "Cuarto menguante")
            }

        return {
            icon: "◔",
            name: tx("Waning crescent", "Menguante")
        }
    }

    function aqiText(value) {
        if (isNaN(value))
            return "--"

        if (value <= 50)
            return tx("Good", "Bueno")

        if (value <= 100)
            return tx("Moderate", "Moderado")

        if (value <= 150)
            return tx("Sensitive groups", "Grupos sensibles")

        if (value <= 200)
            return tx("Unhealthy", "Malo")

        if (value <= 300)
            return tx("Very unhealthy", "Muy malo")

        return tx("Hazardous", "Peligroso")
    }

    function uvColor(value) {
        value = Number(value)

        if (!isFinite(value))
            return "#d8d8d8"

        if (value < 3)
            return "#79d279"

        if (value < 6)
            return "#ffd966"

        if (value < 8)
            return "#ffad5a"

        if (value < 11)
            return "#ff6b6b"

        return "#c78cff"
    }

    function aqiColor(value) {
        value = Number(value)

        if (!isFinite(value))
            return "#d8d8d8"

        if (value <= 50)
            return "#79d279"

        if (value <= 100)
            return "#ffd966"

        if (value <= 150)
            return "#ffad5a"

        if (value <= 200)
            return "#ff6b6b"

        if (value <= 300)
            return "#c78cff"

        return "#b66a83"
    }

    function metricTooltip(symbol) {
        if (symbol === "☂")
            return tx(
                "Precipitation probability today",
                "Probabilidad de precipitación hoy"
            )

        if (symbol === "☀")
            return tx(
                "Maximum UV index today",
                "Índice UV máximo de hoy"
            )

        if (symbol === "☀↑")
            return tx(
                "Sunrise",
                "Salida del sol / Amanecer"
            )

        if (symbol === "☀↓")
            return tx(
                "Sunset",
                "Puesta del sol / Atardecer"
            )

        if (symbol === "◉")
            return tx(
                "Air quality (AQI): overall air pollution index",
                "Calidad del aire (AQI): índice general de contaminación atmosférica"
            )

        if (symbol === "◌")
            return tx(
                "Atmospheric dust concentration",
                "Concentración de polvo atmosférico"
            )

        return tx(
            "Current Moon phase",
            "Fase actual de la Luna"
        )
    }

    /* Finite number, or NaN for null/undefined/empty/non-numeric. */
    function metricNumber(value) {
        if (value === null || value === undefined || value === "")
            return NaN

        var number = Number(value)

        return isFinite(number) ? number : NaN
    }

    function percentText(value) {
        var number = metricNumber(value)

        return isNaN(number)
            ? "--"
            : Math.round(number) + "%"
    }

    function uvText(value) {
        var number = metricNumber(value)

        return "UV " + (
            isNaN(number)
            ? "--"
            : number.toFixed(1)
        )
    }

    /*
     * Open-Meteo air quality is independent of the weather provider:
     * a failure leaves the values at NaN and never touches errorText.
     */
    function refreshAirQuality(lat, lon) {
        var serial = root.weatherRequestSerial

        currentAqi = NaN
        currentDust = NaN
        currentPm25 = NaN

        var url =
            "https://air-quality-api.open-meteo.com/v1/air-quality"
            + "?latitude=" + encodeURIComponent(lat)
            + "&longitude=" + encodeURIComponent(lon)
            + "&current=us_aqi,dust,pm2_5"
            + "&timezone="
            + encodeURIComponent(
                plasmoid.configuration.timezone
                || "auto"
            )

        var request = new XMLHttpRequest()

        request.onreadystatechange = function() {
            if (request.readyState !== 4)
                return

            if (serial !== root.weatherRequestSerial)
                return

            if (request.status !== 200)
                return

            try {
                var data = JSON.parse(request.responseText)

                if (!data.current)
                    return

                currentAqi = data.current.us_aqi
                currentDust = data.current.dust
                currentPm25 = data.current.pm2_5

            } catch (e) {
                console.log(
                    "Nostalgia Weather air quality error:",
                    e
                )
            }
        }

        request.open("GET", url)
        request.send()
    }

    function extendedWeatherCode(
        cloudCover,
        precipitation,
        snowfall
    ) {
        cloudCover = Number(cloudCover)
        precipitation = Number(precipitation)
        snowfall = Number(snowfall)

        if (isFinite(snowfall) && snowfall >= 0.5)
            return 71

        if (isFinite(precipitation)) {
            if (precipitation >= 10)
                return 65

            if (precipitation >= 3)
                return 63

            if (precipitation >= 0.2)
                return 61
        }

        if (!isFinite(cloudCover))
            return 3

        if (cloudCover < 20)
            return 0

        if (cloudCover < 50)
            return 1

        if (cloudCover < 80)
            return 2

        return 3
    }

    function refreshExtendedForecast(
        serial,
        lat,
        lon,
        baseDays
    ) {
        var url =
            "https://ensemble-api.open-meteo.com/v1/ensemble"
            + "?latitude=" + encodeURIComponent(lat)
            + "&longitude=" + encodeURIComponent(lon)
            + "&models=ncep_gefs05_ensemble_mean"
            + "&daily="
            + "temperature_2m_max,"
            + "temperature_2m_min,"
            + "cloud_cover_mean,"
            + "precipitation_sum,"
            + "snowfall_sum"
            + "&temperature_unit="
            + encodeURIComponent(
                root.temperatureUnit
            )
            + "&timezone="
            + encodeURIComponent(
                plasmoid.configuration.timezone
                || "auto"
            )
            + "&forecast_days=30"

        var request = new XMLHttpRequest()

        request.onreadystatechange = function() {
            if (request.readyState !== 4)
                return

            if (serial !== root.weatherRequestSerial)
                return

            if (request.status !== 200) {
                console.log(
                    "Nostalgia Weather extended outlook HTTP error:",
                    request.status,
                    request.responseText
                )

                return
            }

            try {
                var data =
                    JSON.parse(
                        request.responseText
                    )

                if (
                    !data.daily
                    || !data.daily.time
                ) {
                    return
                }

                var days =
                    baseDays.slice()

                for (
                    var i = days.length;
                    i < data.daily.time.length
                        && i < 30;
                    ++i
                ) {
                    days.push({
                        date:
                            data.daily.time[i],

                        code:
                            root.extendedWeatherCode(
                                data.daily.cloud_cover_mean[i],
                                data.daily.precipitation_sum[i],
                                data.daily.snowfall_sum[i]
                            ),

                        max:
                            data.daily.temperature_2m_max[i],

                        min:
                            data.daily.temperature_2m_min[i],

                        precip:
                            data.daily.precipitation_sum[i],

                        precipUnit:
                            "mm",

                        extended:
                            true,

                        uv: NaN,
                        sunrise: "",
                        sunset: ""
                    })
                }

                forecast = days

            } catch (e) {
                console.log(
                    "Nostalgia Weather extended outlook parse error:",
                    e
                )
            }
        }

        request.open("GET", url)
        request.send()
    }

    /*
     * Builds the next-hours strip from the same weather response.
     * Open-Meteo returns timezone-less local timestamps
     * ("YYYY-MM-DDTHH:MM") for the selected location, so they are
     * compared as strings against data.current.time and never go
     * through Date (which would use the computer timezone).
     */
    function parseHourlyForecast(data) {
        var items = []

        try {
            var hourly = data.hourly
            var now = data.current ? data.current.time : ""

            if (!hourly
                    || typeof now !== "string"
                    || now.length < 16
                    || !Array.isArray(hourly.time))
                return items

            var temps = hourly.temperature_2m
            var codes = hourly.weather_code
            var precips = hourly.precipitation_probability
            var days = hourly.is_day

            for (
                var i = 0;
                i < hourly.time.length
                    && items.length < 6;
                ++i
            ) {
                var time = hourly.time[i]

                if (typeof time !== "string"
                        || time.length < 16
                        || time <= now)
                    continue

                var temperature =
                    Array.isArray(temps) && i < temps.length
                    ? Number(temps[i])
                    : NaN

                var code =
                    Array.isArray(codes) && i < codes.length
                    ? Number(codes[i])
                    : NaN

                var hour = Number(time.substring(11, 13))

                if (!isFinite(temperature)
                        || !isFinite(code)
                        || !isFinite(hour))
                    continue

                var precipitation =
                    Array.isArray(precips) && i < precips.length
                    && precips[i] !== null
                    ? Number(precips[i])
                    : NaN

                items.push({
                    time: time,
                    hour: hour,
                    code: code,
                    temperature: temperature,
                    precipitation:
                        isFinite(precipitation)
                        ? precipitation
                        : NaN,
                    isDay:
                        Array.isArray(days)
                        && i < days.length
                        ? Number(days[i]) === 1
                        : true
                })
            }
        } catch (e) {
            console.log(
                "Nostalgia Weather hourly parse error:",
                e
            )

            return []
        }

        return items
    }

    /*
     * Final failure of a refresh cycle (every allowed provider
     * failed). Intermediate provider failures never reach this.
     */
    function failWeather(serial) {
        if (serial !== root.weatherRequestSerial)
            return

        hourlyForecast = []
        loading = false

        errorText =
            tx(
                "Unable to update weather",
                "No se pudo actualizar el clima"
            )
    }

    /*
     * Single place where a normalized provider result mutates the
     * weather state. result:
     *   currentTemperature, apparentTemperature, currentCode,
     *   currentIsDay, forecast, hourlyForecast, forecastLimit,
     *   lat, lon
     */
    function applyWeatherResult(serial, providerId, result) {
        if (serial !== root.weatherRequestSerial)
            return

        currentTemperature = result.currentTemperature
        apparentTemperature = result.apparentTemperature
        currentCode = result.currentCode
        currentIsDay = result.currentIsDay

        forecast = result.forecast
        hourlyForecast = result.hourlyForecast
        forecastProviderLimit = result.forecastLimit

        activeWeatherProvider = providerId
        errorText = ""
        loading = false

        /* The 16-30 day outlook is an Open-Meteo-only extension. */
        if (
            providerId === "open-meteo"
            && Number(
                plasmoid.configuration.forecastDays
                || 7
            ) > 15
        ) {
            refreshExtendedForecast(
                serial,
                result.lat,
                result.lon,
                result.forecast
            )
        }

        refreshAirQuality(result.lat, result.lon)
    }

    function refreshWeather() {
        var serial = ++root.weatherRequestSerial

        var lat = Number(
            String(
                plasmoid.configuration.latitude
            ).replace(",", ".")
        )

        var lon = Number(
            String(
                plasmoid.configuration.longitude
            ).replace(",", ".")
        )

        if (!isFinite(lat) || !isFinite(lon)) {
            hourlyForecast = []
            loading = false
            errorText = tx("Invalid coordinates", "Coordenadas inválidas")
            return
        }

        loading = true
        errorText = ""

        /* Never show hours of another place, timezone or unit. */
        var hourlyKey =
            lat + "|" + lon + "|"
            + (plasmoid.configuration.timezone || "auto")
            + "|" + root.temperatureUnit

        if (hourlyKey !== hourlyRequestKey) {
            hourlyForecast = []
            hourlyRequestKey = hourlyKey
        }

        if (root.weatherProvider === "met-norway") {
            requestMetNorwayWeather(serial, lat, lon)
            return
        }

        /* "auto" (and any unknown value) may fall back to MET Norway. */
        requestOpenMeteoWeather(
            serial,
            lat,
            lon,
            root.weatherProvider !== "open-meteo"
        )
    }

    /*
     * Maps an Open-Meteo forecast response to the normalized result.
     * Returns null when the response is structurally invalid.
     */
    function openMeteoResult(data, lat, lon) {
        if (!data
                || !data.current
                || !data.daily
                || !Array.isArray(data.daily.time)
                || data.daily.time.length === 0
                || !Array.isArray(data.daily.weather_code)
                || !Array.isArray(data.daily.temperature_2m_max)
                || !Array.isArray(data.daily.temperature_2m_min)
                || !Array.isArray(
                       data.daily.precipitation_probability_max)
                || !Array.isArray(data.daily.uv_index_max)
                || !Array.isArray(data.daily.sunrise)
                || !Array.isArray(data.daily.sunset)
                || !isFinite(Number(data.current.temperature_2m))) {
            return null
        }

        var days = []

        for (
            var i = 0;
            i < data.daily.time.length;
            ++i
        ) {
            days.push({
                date:
                    data.daily.time[i],

                code:
                    data.daily.weather_code[i],

                max:
                    data.daily.temperature_2m_max[i],

                min:
                    data.daily.temperature_2m_min[i],

                precip:
                    data.daily
                        .precipitation_probability_max[i],

                uv:
                    data.daily.uv_index_max[i],

                sunrise:
                    data.daily.sunrise[i],

                sunset:
                    data.daily.sunset[i]
            })
        }

        return {
            currentTemperature:
                data.current.temperature_2m,

            apparentTemperature:
                data.current.apparent_temperature,

            currentCode:
                data.current.weather_code,

            currentIsDay:
                data.current.is_day === 1,

            forecast: days,
            hourlyForecast: parseHourlyForecast(data),
            forecastLimit: 30,

            lat: lat,
            lon: lon
        }
    }

    function requestOpenMeteoWeather(
        serial,
        lat,
        lon,
        allowFallback
    ) {
        var url =
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + encodeURIComponent(lat)
            + "&longitude=" + encodeURIComponent(lon)
            + "&current="
            + "temperature_2m,"
            + "apparent_temperature,"
            + "weather_code,"
            + "is_day"
            + "&daily="
            + "weather_code,"
            + "temperature_2m_max,"
            + "temperature_2m_min,"
            + "precipitation_probability_max,"
            + "uv_index_max,"
            + "sunrise,"
            + "sunset"
            + "&hourly="
            + "temperature_2m,"
            + "weather_code,"
            + "precipitation_probability,"
            + "is_day"
            + "&forecast_hours=8"
            + "&temperature_unit="
            + encodeURIComponent(
                root.temperatureUnit
            )
            + "&timezone="
            + encodeURIComponent(
                plasmoid.configuration.timezone
                || "auto"
            )
            +
            "&forecast_days="
            + Math.max(
                3,
                Math.min(
                    15,
                    Number(
                        plasmoid.configuration.forecastDays
                        || 7
                    )
                )
            )

        var request = new XMLHttpRequest()

        request.onreadystatechange = function() {
            if (request.readyState !== 4)
                return

            /* Superseded by a newer refresh: ignore completely. */
            if (serial !== root.weatherRequestSerial)
                return

            var result = null

            if (request.status !== 200) {
                console.log(
                    "Nostalgia Weather weather HTTP error:",
                    request.status,
                    request.responseText
                )
            } else {
                try {
                    result = root.openMeteoResult(
                        JSON.parse(request.responseText),
                        lat,
                        lon
                    )
                } catch (e) {
                    console.log(
                        "Nostalgia Weather parse error:",
                        e
                    )
                }

                if (result === null) {
                    console.log(
                        "Nostalgia Weather Open-Meteo response is invalid"
                    )
                }
            }

            if (result !== null) {
                root.applyWeatherResult(
                    serial,
                    "open-meteo",
                    result
                )
                return
            }

            /* loading stays true while the fallback is in flight. */
            if (allowFallback) {
                root.requestMetNorwayWeather(serial, lat, lon)
                return
            }

            root.failWeather(serial)
        }

        request.open("GET", url)
        request.send()
    }

    /*
     * MET NORWAY LOCATIONFORECAST
     */
    function pad2(value) {
        return (value < 10 ? "0" : "") + value
    }

    /* "rounded to at most four decimals" (service terms). */
    function metCoordinate(value) {
        return String(Number(Number(value).toFixed(4)))
    }

    function metNumber(value) {
        return typeof value === "number" && isFinite(value)
            ? value
            : NaN
    }

    function metTemperature(celsius, fahrenheit) {
        var value = fahrenheit
            ? celsius * 9 / 5 + 32
            : celsius

        return Math.round(value * 10) / 10
    }

    /*
     * Closest existing weather-code model (WMO-like) for a MET
     * symbol_code. Unknown symbols return -1.
     */
    function metSymbolToWeatherCode(symbolCode) {
        var symbol =
            String(symbolCode || "")
                .toLowerCase()
                .replace(/_(day|night|polartwilight)$/, "")

        if (symbol === "")
            return -1

        if (symbol.indexOf("thunder") >= 0)
            return 95

        var heavy = symbol.indexOf("heavy") === 0
        var light = symbol.indexOf("light") === 0
        var showers = symbol.indexOf("showers") >= 0

        if (symbol.indexOf("sleet") >= 0) {
            if (showers)
                return 81

            return light ? 66 : 67
        }

        if (symbol.indexOf("snow") >= 0) {
            if (showers)
                return heavy ? 86 : 85

            if (heavy)
                return 75

            return light ? 71 : 73
        }

        if (symbol.indexOf("rain") >= 0) {
            if (showers) {
                if (heavy)
                    return 82

                return light ? 80 : 81
            }

            if (heavy)
                return 65

            return light ? 61 : 63
        }

        if (symbol === "clearsky")
            return 0

        if (symbol === "fair")
            return 1

        if (symbol === "partlycloudy")
            return 2

        if (symbol === "cloudy")
            return 3

        if (symbol === "fog")
            return 45

        return -1
    }

    function metSymbolIsDay(symbolCode) {
        return !/_night$/.test(
            String(symbolCode || "").toLowerCase()
        )
    }

    /* Optional MET forecast period: symbol and rain probability. */
    function metPeriod(period) {
        var summary = period ? period.summary : null
        var details = period ? period.details : null

        return {
            symbol:
                summary
                && typeof summary.symbol_code === "string"
                ? summary.symbol_code
                : "",

            probability:
                metNumber(
                    details
                    ? details.probability_of_precipitation
                    : undefined
                )
        }
    }

    /*
     * LOCATION-LOCAL TIME FROM A UTC INSTANT
     *
     * Qt can parse an IANA zone id ("tttt"), but cannot print an
     * instant in a zone. So the zone is used in the parsing
     * direction: a wall-clock string + zone -> real instant. The
     * zone offset for the timestamp is found from that (wall
     * clock = instant + offset), the instant is shifted by it, and
     * the shifted Date is read with UTC getters, so the host
     * timezone never leaks in. DST is resolved per timestamp.
     */
    function zoneInstant(wallMs, zone) {
        try {
            var wall = new Date(wallMs)

            var text =
                wall.getUTCFullYear()
                + "-" + pad2(wall.getUTCMonth() + 1)
                + "-" + pad2(wall.getUTCDate())
                + " " + pad2(wall.getUTCHours())
                + ":" + pad2(wall.getUTCMinutes())
                + ":" + pad2(wall.getUTCSeconds())
                + " " + zone

            var parsed =
                Date.fromLocaleString(
                    Qt.locale("en_US"),
                    text,
                    "yyyy-MM-dd hh:mm:ss tttt"
                )

            var value = parsed ? parsed.getTime() : NaN

            return isFinite(value) ? value : NaN
        } catch (e) {
            return NaN
        }
    }

    /* null: the zone could not be parsed at all. */
    function zoneOffsetSolve(ms, zone) {
        var offset = 0

        for (var i = 0; i < 4; ++i) {
            var back = zoneInstant(ms + offset, zone)

            if (!isFinite(back))
                return null

            var next = ms + offset - back

            if (next === offset)
                return { offset: offset, exact: true }

            offset = next
        }

        return { offset: offset, exact: false }
    }

    /*
     * tz = { zone, offset } keeps the last offset as the first
     * candidate, so a series normally costs one parse per entry.
     * Returns { date: "YYYY-MM-DD", hour, minute } or null.
     */
    function zonedParts(ms, tz) {
        var offset = null

        if (tz.offset !== null
                && zoneInstant(ms + tz.offset, tz.zone) === ms) {
            offset = tz.offset
        }

        if (offset === null) {
            var solved = zoneOffsetSolve(ms, tz.zone)

            if (solved === null)
                return null

            if (solved.exact) {
                offset = solved.offset
            } else {
                /* Near a DST transition: try the neighbouring days. */
                var around = [ms - 86400000, ms + 86400000]

                for (var i = 0; i < around.length; ++i) {
                    var other = zoneOffsetSolve(around[i], tz.zone)

                    if (other !== null
                            && other.exact
                            && zoneInstant(
                                   ms + other.offset,
                                   tz.zone) === ms) {
                        offset = other.offset
                        break
                    }
                }

                /* Repeated wall-clock hour: best available offset. */
                if (offset === null)
                    offset = solved.offset
            }
        }

        tz.offset = offset

        var shifted = new Date(ms + offset)

        return {
            date:
                shifted.getUTCFullYear()
                + "-" + pad2(shifted.getUTCMonth() + 1)
                + "-" + pad2(shifted.getUTCDate()),

            hour: shifted.getUTCHours(),
            minute: shifted.getUTCMinutes()
        }
    }

    /*
     * MET JSON -> small normalized payload (cacheable):
     *   days:  { date, code, max, min, precip|null, uv|null }
     *   hours: up to 13 entries from "now" onwards
     *          { t, lt, h, tc, ap|null, c|null, d, h1, p|null }
     * Temperatures are already in the requested unit. Returns null
     * when the response or the zone conversion is unusable.
     */
    function metNormalize(data, zone, unit) {
        if (!data
                || !data.properties
                || !Array.isArray(data.properties.timeseries)) {
            return null
        }

        if (!zone || zone === "auto")
            return null

        var fahrenheit = unit === "fahrenheit"
        var tz = { zone: zone, offset: null }
        var series = data.properties.timeseries
        var samples = []

        for (var i = 0; i < series.length; ++i) {
            var item = series[i]

            if (!item
                    || typeof item.time !== "string"
                    || !item.data) {
                continue
            }

            var t = Date.parse(item.time)

            if (!isFinite(t))
                continue

            var details =
                item.data.instant
                && item.data.instant.details
                ? item.data.instant.details
                : {}

            var celsius = metNumber(details.air_temperature)

            if (!isFinite(celsius))
                continue

            var apparent = metNumber(details.apparent_air_temperature)

            var p1 = metPeriod(item.data.next_1_hours)
            var p6 = metPeriod(item.data.next_6_hours)
            var p12 = metPeriod(item.data.next_12_hours)

            var probability = p1.probability

            if (!isFinite(probability))
                probability = p6.probability

            if (!isFinite(probability))
                probability = p12.probability

            var parts = zonedParts(t, tz)

            if (parts === null)
                return null

            samples.push({
                t: t,
                parts: parts,

                temperature: metTemperature(celsius, fahrenheit),

                apparent:
                    isFinite(apparent)
                    ? metTemperature(apparent, fahrenheit)
                    : NaN,

                uv: metNumber(details.ultraviolet_index_clear_sky),

                hourSymbol: p1.symbol,
                symbol: p1.symbol || p6.symbol || p12.symbol,

                hourProbability: p1.probability,
                probability: probability
            })
        }

        if (samples.length === 0)
            return null

        samples.sort(function(a, b) { return a.t - b.t })

        /* Daily groups by LOCATION-LOCAL date. */
        var groups = {}
        var order = []

        for (var s = 0; s < samples.length; ++s) {
            var sample = samples[s]
            var date = sample.parts.date
            var group = groups[date]

            if (!group) {
                group = {
                    date: date,
                    max: -Infinity,
                    min: Infinity,
                    uv: NaN,
                    precip: NaN,
                    code: -1,
                    codeDistance: Infinity
                }

                groups[date] = group
                order.push(date)
            }

            group.max = Math.max(group.max, sample.temperature)
            group.min = Math.min(group.min, sample.temperature)

            if (isFinite(sample.uv)
                    && (!isFinite(group.uv) || sample.uv > group.uv)) {
                group.uv = sample.uv
            }

            if (isFinite(sample.probability)
                    && (!isFinite(group.precip)
                        || sample.probability > group.precip)) {
                group.precip = sample.probability
            }

            var code = metSymbolToWeatherCode(sample.symbol)

            if (code >= 0) {
                var distance =
                    Math.abs(
                        sample.parts.hour
                        + sample.parts.minute / 60
                        - 12
                    )

                if (distance < group.codeDistance) {
                    group.code = code
                    group.codeDistance = distance
                }
            }
        }

        var days = []

        for (var g = 0; g < order.length; ++g) {
            var entry = groups[order[g]]

            if (!isFinite(entry.max) || !isFinite(entry.min))
                continue

            days.push({
                date: entry.date,
                code: entry.code,
                max: entry.max,
                min: entry.min,
                precip: isFinite(entry.precip) ? entry.precip : null,
                uv: isFinite(entry.uv) ? entry.uv : null
            })
        }

        if (days.length === 0)
            return null

        /* "Current" entry and the hours after it. */
        var nowMs = Date.now()
        var currentIndex = 0

        for (var n = 0; n < samples.length; ++n) {
            if (samples[n].t <= nowMs)
                currentIndex = n
        }

        var hours = []

        for (
            var h = currentIndex;
            h < samples.length && hours.length < 13;
            ++h
        ) {
            var point = samples[h]
            var currentSymbol = point.symbol

            hours.push({
                t: point.t,

                lt:
                    point.parts.date
                    + "T" + pad2(point.parts.hour)
                    + ":" + pad2(point.parts.minute),

                h: point.parts.hour,
                tc: point.temperature,

                ap:
                    isFinite(point.apparent)
                    ? point.apparent
                    : null,

                c:
                    currentSymbol
                    ? metSymbolToWeatherCode(currentSymbol)
                    : null,

                d: metSymbolIsDay(currentSymbol),

                /* The hourly strip needs a real next_1_hours symbol. */
                h1: point.hourSymbol !== "",

                p:
                    isFinite(point.hourProbability)
                    ? point.hourProbability
                    : null
            })
        }

        return { days: days, hours: hours }
    }

    function metPayloadValid(payload) {
        return !!payload
            && Array.isArray(payload.days)
            && payload.days.length > 0
            && Array.isArray(payload.hours)
            && payload.hours.length > 0
    }

    /*
     * Normalized payload -> UI result, evaluated against "now" so a
     * cached payload still yields the right current/hourly entries.
     */
    function metBuildResult(payload, zone, lat, lon) {
        if (!metPayloadValid(payload))
            return null

        var nowMs = Date.now()
        var today = zonedParts(nowMs, { zone: zone, offset: null })

        if (today === null)
            return null

        var days = []

        for (var i = 0; i < payload.days.length; ++i) {
            var day = payload.days[i]

            if (!day
                    || typeof day.date !== "string"
                    || day.date < today.date
                    || !isFinite(Number(day.max))
                    || !isFinite(Number(day.min))) {
                continue
            }

            days.push({
                date: day.date,
                code: Number(day.code),
                max: Number(day.max),
                min: Number(day.min),
                precip: metricNumber(day.precip),
                uv: metricNumber(day.uv),
                sunrise: "",
                sunset: ""
            })
        }

        if (days.length === 0)
            return null

        var hours = payload.hours
        var current = hours[0]

        for (var n = 0; n < hours.length; ++n) {
            if (hours[n].t <= nowMs)
                current = hours[n]
        }

        var hourly = []

        for (var h = 0; h < hours.length && hourly.length < 6; ++h) {
            var point = hours[h]

            if (!(point.t > nowMs)
                    || !point.h1
                    || point.c === null
                    || !isFinite(Number(point.tc))) {
                continue
            }

            hourly.push({
                time: point.lt,
                hour: point.h,
                code: Number(point.c),
                temperature: Number(point.tc),

                /* next_1_hours probability only; never a 6 h value. */
                precipitation: metricNumber(point.p),

                isDay: point.d === true
            })
        }

        return {
            currentTemperature: Number(current.tc),

            apparentTemperature:
                current.ap === null
                ? NaN
                : Number(current.ap),

            currentCode:
                current.c === null
                ? -1
                : Number(current.c),

            currentIsDay: current.d === true,

            forecast: days,
            hourlyForecast: hourly,
            forecastLimit: days.length,

            lat: lat,
            lon: lon
        }
    }

    function parseHttpDate(text) {
        if (!text)
            return NaN

        var match =
            /^[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$/
                .exec(String(text).trim())

        if (match) {
            var month =
                ["jan", "feb", "mar", "apr", "may", "jun",
                 "jul", "aug", "sep", "oct", "nov", "dec"]
                    .indexOf(match[2].toLowerCase())

            if (month >= 0) {
                return Date.UTC(
                    Number(match[3]),
                    month,
                    Number(match[1]),
                    Number(match[4]),
                    Number(match[5]),
                    Number(match[6])
                )
            }
        }

        return Date.parse(String(text))
    }

    /* Expires header, or a conservative 10 minutes when unusable. */
    function metExpiry(expiresHeader) {
        var expires = parseHttpDate(expiresHeader)

        if (isFinite(expires) && expires > Date.now())
            return expires

        return Date.now() + 10 * 60 * 1000
    }

    function metCacheLoad(key) {
        metNorwayCacheSettings.sync()

        try {
            if (decodeURIComponent(
                    String(metNorwayCacheSettings.value("key", ""))
                ) !== key) {
                return null
            }

            var expires =
                Number(
                    metNorwayCacheSettings.value("expiresEpoch", 0)
                )

            var payload =
                JSON.parse(
                    decodeURIComponent(
                        String(
                            metNorwayCacheSettings.value("payload", "")
                        )
                    )
                )

            if (!isFinite(expires) || !metPayloadValid(payload))
                return null

            return {
                expiresEpoch: expires,

                lastModified:
                    decodeURIComponent(
                        String(
                            metNorwayCacheSettings.value(
                                "lastModified",
                                ""
                            )
                        )
                    ),

                payload: payload
            }
        } catch (e) {
            return null
        }
    }

    /*
     * Text values are percent-encoded so commas and quotes in the
     * HTTP date / JSON cannot be reinterpreted by the ini format.
     */
    function metCacheSave(key, expiresEpoch, lastModified, payload) {
        try {
            metNorwayCacheSettings.setValue(
                "key", encodeURIComponent(key)
            )
            metNorwayCacheSettings.setValue(
                "expiresEpoch", expiresEpoch
            )
            metNorwayCacheSettings.setValue(
                "lastModified",
                encodeURIComponent(lastModified || "")
            )
            metNorwayCacheSettings.setValue(
                "payload",
                encodeURIComponent(JSON.stringify(payload))
            )

            metNorwayCacheSettings.sync()
        } catch (e) {
            console.log(
                "Nostalgia Weather MET Norway cache error:",
                e
            )
        }
    }

    function responseHeader(request, name) {
        try {
            return request.getResponseHeader(name) || ""
        } catch (e) {
            return ""
        }
    }

    function requestMetNorwayWeather(serial, lat, lon) {
        var latText = metCoordinate(lat)
        var lonText = metCoordinate(lon)
        var zone = String(plasmoid.configuration.timezone || "")
        var unit = root.temperatureUnit

        var key = [latText, lonText, zone, unit].join("|")

        var cached = metCacheLoad(key)

        if (cached !== null) {
            if (Date.now() < cached.expiresEpoch) {
                var fresh =
                    metBuildResult(cached.payload, zone, lat, lon)

                if (fresh !== null) {
                    applyWeatherResult(serial, "met-norway", fresh)
                    return
                }

                /* Unusable payload: ignore it and ask MET. */
                cached = null
            }
        }

        var url =
            "https://api.met.no/weatherapi/locationforecast/2.0/complete"
            + "?lat=" + encodeURIComponent(latText)
            + "&lon=" + encodeURIComponent(lonText)

        var request = new XMLHttpRequest()

        request.onreadystatechange = function() {
            if (request.readyState !== 4)
                return

            /* Superseded by a newer refresh: ignore completely. */
            if (serial !== root.weatherRequestSerial)
                return

            var status = request.status

            if (status === 304 && cached !== null) {
                var reused =
                    root.metBuildResult(
                        cached.payload,
                        zone,
                        lat,
                        lon
                    )

                if (reused !== null) {
                    root.metCacheSave(
                        key,
                        root.metExpiry(
                            root.responseHeader(request, "Expires")
                        ),
                        root.responseHeader(request, "Last-Modified")
                            || cached.lastModified,
                        cached.payload
                    )

                    root.applyWeatherResult(
                        serial,
                        "met-norway",
                        reused
                    )

                    return
                }

                console.log(
                    "Nostalgia Weather MET Norway cached payload is invalid"
                )

                root.failWeather(serial)
                return
            }

            if (status !== 200) {
                console.log(
                    "Nostalgia Weather MET Norway HTTP error:",
                    status
                )

                root.failWeather(serial)
                return
            }

            var payload = null
            var result = null

            try {
                payload =
                    root.metNormalize(
                        JSON.parse(request.responseText),
                        zone,
                        unit
                    )

                if (payload !== null) {
                    result =
                        root.metBuildResult(
                            payload,
                            zone,
                            lat,
                            lon
                        )
                }
            } catch (e) {
                console.log(
                    "Nostalgia Weather MET Norway parse error:",
                    e
                )
            }

            if (result === null) {
                console.log(
                    "Nostalgia Weather MET Norway response is invalid"
                )

                root.failWeather(serial)
                return
            }

            root.metCacheSave(
                key,
                root.metExpiry(
                    root.responseHeader(request, "Expires")
                ),
                root.responseHeader(request, "Last-Modified"),
                payload
            )

            root.applyWeatherResult(serial, "met-norway", result)
        }

        request.open("GET", url)

        /* MET Norway requires an identifying User-Agent. */
        request.setRequestHeader(
            "User-Agent",
            "NostalgiaWeather/0.4 (+https://github.com/Karuho/nostalgia-weather)"
        )

        request.setRequestHeader("Accept", "application/json")

        if (cached !== null && cached.lastModified) {
            request.setRequestHeader(
                "If-Modified-Since",
                cached.lastModified
            )
        }

        request.send()
    }

    Timer {
        interval:
            Math.max(
                10,
                plasmoid.configuration.updateMinutes
            )
            * 60
            * 1000

        repeat: true
        running: true

        onTriggered:
            root.refreshWeather()
    }

    Timer {
        id: configurationRefreshTimer

        interval: 100
        repeat: false

        onTriggered:
            root.refreshWeather()
    }

    /* Coalesces the four related configuration changes. */
    Timer {
        id: sharedLocationPublishTimer

        interval: 200
        repeat: false

        onTriggered:
            root.publishSharedLocation()
    }

    /*
     * Qt Settings instances do not notify each other, so each
     * instance checks the shared revision once per second.
     */
    Timer {
        interval: 1000
        repeat: true
        running: root.sharedLocationReady

        onTriggered:
            root.pollSharedLocation()
    }

    Component.onCompleted: {
        sharedLocationSettings.sync()

        /*
         * Import only; never publish at startup so the first
         * instance to start cannot overwrite the others.
         */
        root.importSharedLocation()

        /* Changes from here on may be published. */
        sharedLocationReady = true

        /* Imported coordinates already scheduled a refresh. */
        if (!configurationRefreshTimer.running)
            refreshWeather()
    }

    onTemperatureUnitChanged:
        configurationRefreshTimer.restart()

    onWeatherProviderChanged:
        configurationRefreshTimer.restart()

    onConfiguredLocationNameChanged:
        scheduleSharedLocationPublish()

    onConfiguredLatitudeChanged: {
        configurationRefreshTimer.restart()
        scheduleSharedLocationPublish()
    }

    onConfiguredLongitudeChanged: {
        configurationRefreshTimer.restart()
        scheduleSharedLocationPublish()
    }

    onConfiguredTimezoneChanged: {
        configurationRefreshTimer.restart()
        scheduleSharedLocationPublish()
    }

    onConfiguredForecastDaysChanged:
        configurationRefreshTimer.restart()

    /*
     * PANEL / SYSTEM TRAY
     */
    compactRepresentation: Item {
        implicitWidth: 28
        implicitHeight: 28

        Kirigami.Icon {
            anchors.fill: parent
            anchors.margins: 3

            source:
                root.weatherIcon(
                    root.currentCode,
                    root.currentIsDay
                )
        }

        MouseArea {
            anchors.fill: parent

            onClicked:
                plasmoid.expanded =
                    !plasmoid.expanded
        }
    }

    /*
     * ESCRITORIO / POPUP DEL SYSTEM TRAY
     */
    fullRepresentation: Item {
        id: card

        Layout.minimumWidth: 300

        Layout.minimumHeight:
            width < 390 ? 340 : 205

        Layout.preferredWidth: 430

        Layout.preferredHeight:
            width < 390 ? 340 : 305

        readonly property int requestedDays:
            Math.max(
                3,
                Math.min(
                    30,
                    Number(
                        plasmoid.configuration.forecastDays
                        || 7
                    )
                )
            )

        readonly property int adaptiveCapacity:
            width < 370
            ? 5
            : (
                width < 560
                ? 7
                : (
                    width < 760
                    ? 10
                    : (
                        width < 900
                        || height < 520
                        ? 16
                        : 30
                    )
                )
            )

        readonly property int visibleDays:
            Math.min(
                requestedDays,
                adaptiveCapacity,
                root.forecastProviderLimit
            )

        readonly property bool extendedForecast:
            visibleDays > 7

        readonly property int forecastColumns:
            visibleDays <= 7
            ? Math.max(1, visibleDays)
            : (
                visibleDays <= 10
                ? 5
                : (
                    visibleDays <= 16
                    ? 8
                    : 10
                )
            )

        readonly property int forecastRows:
            visibleDays > 0
            ? Math.ceil(
                  visibleDays
                  / forecastColumns
              )
            : 0

        readonly property bool showDetails:
            height >= 260

        readonly property bool showAirDetails:
            height >= 290

        Rectangle {
            anchors.fill: parent

            radius: Math.max(
                8,
                Math.min(14, width / 28)
            )

            border.width: 1
            border.color: theme.cardBorder

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.cardGradientTop
                }

                GradientStop {
                    position: 0.42
                    color: theme.cardGradientMiddle
                }

                GradientStop {
                    position: 1.0
                    color: theme.cardGradientBottom
                }
            }
        }

        // Frutiger Aero sky / glass bloom
        Rectangle {
            visible: theme.aero

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 1
            }

            height: parent.height * 0.30
            radius: Math.max(
                7,
                Math.min(13, parent.width / 28)
            )

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.aeroSkyGlowTop
                }

                GradientStop {
                    position: 1.0
                    color: theme.aeroSkyGlowBottom
                }
            }
        }

        // Frutiger Aero luminous horizon band
        Rectangle {
            visible: theme.aero

            anchors {
                left: parent.left
                right: parent.right
                margins: 1
            }

            y: parent.height * 0.42
            height: parent.height * 0.13

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.aeroHorizonTop
                }

                GradientStop {
                    position: 0.5
                    color: theme.aeroHorizonCenter
                }

                GradientStop {
                    position: 1.0
                    color: theme.aeroHorizonBottom
                }
            }
        }

        // Frutiger Aero fresh lower glow
        Rectangle {
            visible: theme.aero

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 1
            }

            height: parent.height * 0.30
            radius: Math.max(
                7,
                Math.min(13, parent.width / 28)
            )

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.aeroFreshGlowTop
                }

                GradientStop {
                    position: 1.0
                    color: theme.aeroFreshGlowBottom
                }
            }
        }

        // Frutiger Aero specular glass highlight
        Rectangle {
            visible: theme.aero

            x: parent.width * 0.05
            y: parent.height * 0.035
            width: parent.width * 0.62
            height: parent.height * 0.15

            radius: height / 2

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.aeroSpecular
                }

                GradientStop {
                    position: 1.0
                    color: theme.aeroSpecularSoft
                }
            }
        }

        // Rose Quartz soft pink upper bloom
        Rectangle {
            visible: theme.rose

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 1
            }

            height: parent.height * 0.32
            radius: Math.max(
                7,
                Math.min(13, parent.width / 28)
            )

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.roseBloomTop
                }

                GradientStop {
                    position: 1.0
                    color: theme.roseBloomBottom
                }
            }
        }

        // Rose Quartz pearlescent central glow
        Rectangle {
            visible: theme.rose

            anchors {
                left: parent.left
                right: parent.right
                margins: 1
            }

            y: parent.height * 0.40
            height: parent.height * 0.16

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.rosePearlTop
                }

                GradientStop {
                    position: 0.5
                    color: theme.rosePearlCenter
                }

                GradientStop {
                    position: 1.0
                    color: theme.rosePearlBottom
                }
            }
        }

        // Rose Quartz lavender / rose lower glow
        Rectangle {
            visible: theme.rose

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 1
            }

            height: parent.height * 0.32
            radius: Math.max(
                7,
                Math.min(13, parent.width / 28)
            )

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.roseLowerGlowTop
                }

                GradientStop {
                    position: 1.0
                    color: theme.roseLowerGlowBottom
                }
            }
        }

        // Rose Quartz glossy specular highlight
        Rectangle {
            visible: theme.rose

            x: parent.width * 0.05
            y: parent.height * 0.035
            width: parent.width * 0.58
            height: parent.height * 0.13

            radius: height / 2

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.roseSpecular
                }

                GradientStop {
                    position: 1.0
                    color: theme.roseSpecularSoft
                }
            }
        }

        // Astral Nebula violet / blue upper nebula glow
        Rectangle {
            visible: theme.astral

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 1
            }

            height: parent.height * 0.34
            radius: Math.max(
                7,
                Math.min(13, parent.width / 28)
            )

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.astralNebulaTop
                }

                GradientStop {
                    position: 1.0
                    color: theme.astralNebulaBottom
                }
            }
        }

        // Astral Nebula electric-purple horizon glow
        Rectangle {
            visible: theme.astral

            anchors {
                left: parent.left
                right: parent.right
                margins: 1
            }

            y: parent.height * 0.42
            height: parent.height * 0.14

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.astralHorizonTop
                }

                GradientStop {
                    position: 0.5
                    color: theme.astralHorizonCenter
                }

                GradientStop {
                    position: 1.0
                    color: theme.astralHorizonBottom
                }
            }
        }

        // Astral Nebula deep indigo lower atmosphere
        Rectangle {
            visible: theme.astral

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 1
            }

            height: parent.height * 0.34
            radius: Math.max(
                7,
                Math.min(13, parent.width / 28)
            )

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.astralAtmosphereTop
                }

                GradientStop {
                    position: 1.0
                    color: theme.astralAtmosphereBottom
                }
            }
        }

        // Astral Nebula static star field
        Item {
            visible: theme.astral

            anchors.fill: parent

            Repeater {
                model: theme.astralStars

                Rectangle {
                    width: modelData[2]
                    height: modelData[2]
                    radius: width / 2

                    x: parent.width * modelData[0] - width / 2
                    y: parent.height * modelData[1] - height / 2

                    color: modelData[3]
                        ? theme.astralStar
                        : theme.astralStarDim
                }
            }
        }

        // Astral Nebula specular glass highlight
        Rectangle {
            visible: theme.astral

            x: parent.width * 0.05
            y: parent.height * 0.035
            width: parent.width * 0.56
            height: parent.height * 0.12

            radius: height / 2

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.astralSpecular
                }

                GradientStop {
                    position: 1.0
                    color: theme.astralSpecularSoft
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 2
            }

            height: parent.height * 0.35
            radius: 12

            color: theme.cardTopGloss
        }

        ColumnLayout {
            anchors.fill: parent

            anchors.margins: Math.max(
                10,
                Math.min(16, parent.width / 26)
            )

            spacing: 5

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    Layout.fillWidth: true

                    visible:
                        plasmoid.configuration.showDate

                    text:
                        root.today !== null
                        ? root.longDate(
                              root.today.date
                          )
                        : ""

                    color: theme.dateText

                    font.pixelSize:
                        Math.max(
                            12,
                            Math.min(
                                14,
                                card.width / 34
                            )
                        )

                    font.bold: true
                }

                PlasmaComponents.ToolButton {


                    icon.name: "configure"

                    onClicked: {
                        var action =
                            plasmoid.internalAction("configure")

                        if (action)
                            action.trigger()
                    }

                    PlasmaComponents.ToolTip {
                        text: root.tx("Settings", "Configuración")
                    }
                }

                PlasmaComponents.ToolButton {


                    icon.name: "view-refresh"

                    enabled: !root.loading

                    onClicked:
                        root.refreshWeather()

                    PlasmaComponents.ToolTip {
                        text: root.tx("Refresh", "Actualizar")
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    PlasmaComponents.Label {
                        Layout.fillWidth: true

                        text: root.locationName

                        color: theme.primaryText

                        font.bold: true

                        font.pixelSize:
                            Math.max(
                                15,
                                Math.min(
                                    20,
                                    card.width / 21
                                )
                            )

                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        text:
                            root.weatherText(
                                root.currentCode
                            )

                        color: theme.secondaryText

                        font.pixelSize: 12
                    }

                    PlasmaComponents.Label {
                        visible:
                            plasmoid.configuration.showFeelsLike
                            && !isNaN(
                                root.apparentTemperature
                            )

                        text:
                            tx("Feels like", "Sensación")
                            + " "
                            + Math.round(
                                root.apparentTemperature
                            )
                            + "°"

                        color: theme.mutedText
                        font.pixelSize: 10
                    }
                }

                Kirigami.Icon {
                    source:
                        root.weatherIcon(
                            root.currentCode,
                            root.currentIsDay
                        )

                    Layout.preferredWidth:
                        Math.max(
                            54,
                            Math.min(
                                76,
                                card.width * 0.18
                            )
                        )

                    Layout.preferredHeight:
                        Layout.preferredWidth
                }

                PlasmaComponents.Label {
                    text:
                        isNaN(
                            root.currentTemperature
                        )
                        ? "--°"
                        : Math.round(
                              root.currentTemperature
                          )
                          + (
                              root.temperatureUnit
                                  === "fahrenheit"
                              ? "°F"
                              : "°C"
                          )

                    color: theme.primaryText

                    font.bold: true

                    font.pixelSize:
                        Math.max(
                            36,
                            Math.min(
                                54,
                                card.width / 8
                            )
                        )
                }
            }

            GridLayout {
                visible:
                    card.showDetails
                    && root.today !== null
                    && (
                        plasmoid.configuration.showPrecipitation
                        || plasmoid.configuration.showUv
                        || plasmoid.configuration.showSun
                    )

                Layout.fillWidth: true

                Layout.preferredHeight:
                    visible
                    ? (
                        card.width < 390
                        ? 57
                        : 28
                    )
                    : 0

                Layout.minimumHeight:
                    Layout.preferredHeight

                Layout.maximumHeight:
                    Layout.preferredHeight

                columns:
                    card.width < 390 ? 2 : 4

                columnSpacing: 6
                rowSpacing: 3

                Repeater {
                    model:
                        root.today === null
                        ? []
                        : [
                            {
                                symbol: "☂",
                                enabled:
                                    plasmoid.configuration.showPrecipitation,
                                value:
                                    root.percentText(
                                        root.today.precip
                                    ),
                                tooltip:
                                    i18n(
                                        "Probabilidad de precipitación hoy"
                                    ),
                                accent: "#8fd3ff"
                            },
                            {
                                symbol: "☀",
                                enabled:
                                    plasmoid.configuration.showUv,
                                value:
                                    root.uvText(
                                        root.today.uv
                                    ),
                                tooltip:
                                    i18n(
                                        "Índice UV máximo de hoy"
                                    ),
                                accent:
                                    root.uvColor(
                                        root.today.uv
                                    )
                            },
                            {
                                symbol: "☀↑",
                                enabled:
                                    plasmoid.configuration.showSun,
                                value:
                                    root.timePart(
                                        root.today.sunrise
                                    ),
                                tooltip:
                                    i18n(
                                        "Salida del sol / Amanecer"
                                    ),
                                accent: "#ffd66b"
                            },
                            {
                                symbol: "☀↓",
                                enabled:
                                    plasmoid.configuration.showSun,
                                value:
                                    root.timePart(
                                        root.today.sunset
                                    ),
                                tooltip:
                                    i18n(
                                        "Puesta del sol / Atardecer"
                                    ),
                                accent: "#ffad73"
                            }
                        ]

                    delegate: Item {
                        visible:
                            modelData.enabled === undefined
                            ? true
                            : modelData.enabled

                        Layout.fillWidth: visible
                        implicitHeight:
                            visible ? 26 : 0

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            PlasmaComponents.Label {
                                text: modelData.symbol
                                color: modelData.accent

                                font.bold: true

                                font.pixelSize:
                                    Math.max(
                                        14,
                                        Math.min(
                                            18,
                                            card.width / 26
                                        )
                                    )
                            }

                            PlasmaComponents.Label {
                                text: modelData.value

                                color: theme.metricText

                                font.pixelSize:
                                    Math.max(
                                        10,
                                        Math.min(
                                            12,
                                            card.width / 35
                                        )
                                    )
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton

                            QQC2.ToolTip.visible:
                                containsMouse

                            QQC2.ToolTip.delay: 300

                            QQC2.ToolTip.text:
                                root.metricTooltip(modelData.symbol)
                        }
                    }
                }
            }

            GridLayout {
                id: secondaryMetricsGrid

                visible:
                    card.showAirDetails
                    && root.today !== null
                    && (
                        plasmoid.configuration.showAirQuality
                        || plasmoid.configuration.showDust
                        || plasmoid.configuration.showMoon
                    )

                readonly property bool compact:
                    card.width < 390

                Layout.fillWidth: true

                Layout.preferredHeight:
                    visible
                    ? (
                        compact
                        ? 55
                        : 28
                    )
                    : 0

                Layout.minimumHeight:
                    Layout.preferredHeight

                Layout.maximumHeight:
                    Layout.preferredHeight

                columns:
                    compact ? 2 : 3

                columnSpacing: 8
                rowSpacing: 3

                Repeater {
                    model:
                        root.today === null
                        ? []
                        : [
                        {
                            symbol: "◉",
                            enabled:
                                plasmoid.configuration.showAirQuality,
                            value:
                                root.tx("Air", "Aire")
                                + " "
                                + (
                                    isNaN(root.currentAqi)
                                    ? "--"
                                    : Math.round(
                                        root.currentAqi
                                    )
                                )
                                + " · "
                                + root.aqiText(
                                    root.currentAqi
                                ),

                            compactValue:
                                "AQI "
                                + (
                                    isNaN(root.currentAqi)
                                    ? "--"
                                    : Math.round(
                                        root.currentAqi
                                    )
                                ),
                            tooltip:
                                i18n(
                                    "Calidad del aire (AQI): índice general de contaminación atmosférica"
                                ),
                            accent:
                                root.aqiColor(
                                    root.currentAqi
                                )
                        },
                        {
                            symbol: "◌",
                            enabled:
                                plasmoid.configuration.showDust,
                            value:
                                root.tx("Dust", "Polvo")
                                + " "
                                + (
                                    isNaN(root.currentDust)
                                    ? "--"
                                    : Number(
                                        root.currentDust
                                    ).toFixed(1)
                                )
                                + " µg/m³",

                            compactValue:
                                (
                                    isNaN(root.currentDust)
                                    ? "--"
                                    : Number(
                                        root.currentDust
                                    ).toFixed(1)
                                )
                                + " µg/m³",
                            tooltip:
                                i18n(
                                    "Polvo presente en el ambiente"
                                ),
                            accent: "#d9bd91"
                        },
                        {
                            enabled:
                                plasmoid.configuration.showMoon,

                            wide: true,

                            symbol:
                                root.today !== null
                                ? root.moonInfo(
                                      root.today.date
                                  ).icon
                                : "○",
                            value:
                                root.today !== null
                                ? root.moonInfo(
                                      root.today.date
                                  ).name
                                : "--",

                            compactValue:
                                root.today !== null
                                ? root.moonInfo(
                                      root.today.date
                                  ).name
                                : "--",
                            tooltip:
                                i18n(
                                    "Fase actual de la Luna"
                                ),
                            accent: "#dedbff"
                        }
                    ]

                    delegate: Item {
                        visible:
                            modelData.enabled === undefined
                            ? true
                            : modelData.enabled

                        Layout.fillWidth: visible

                        Layout.columnSpan:
                            secondaryMetricsGrid.compact
                            && modelData.wide === true
                            ? 2
                            : 1

                        implicitHeight:
                            visible ? 26 : 0

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            PlasmaComponents.Label {
                                text: modelData.symbol
                                color: modelData.accent

                                font.bold: true

                                font.pixelSize:
                                    Math.max(
                                        14,
                                        Math.min(
                                            18,
                                            card.width / 26
                                        )
                                    )
                            }

                            PlasmaComponents.Label {
                                text:
                                    secondaryMetricsGrid.compact
                                    ? modelData.compactValue
                                    : modelData.value

                                elide: Text.ElideRight

                                Layout.maximumWidth:
                                    secondaryMetricsGrid.compact
                                    ? Math.max(
                                          60,
                                          card.width / 2 - 48
                                      )
                                    : Math.max(
                                          46,
                                          card.width / 3 - 32
                                      )

                                color: theme.airMetricText

                                font.pixelSize:
                                    Math.max(
                                        10,
                                        Math.min(
                                            12,
                                            card.width / 36
                                        )
                                    )
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton

                            QQC2.ToolTip.visible:
                                containsMouse

                            QQC2.ToolTip.delay: 300

                            QQC2.ToolTip.text:
                                root.metricTooltip(modelData.symbol)
                        }
                    }
                }
            }

            Item {
                id: hourlyArea

                Layout.fillWidth: true

                Layout.fillHeight:
                    !card.extendedForecast

                Layout.minimumHeight: 0

                Item {
                    id: hourlyStrip

                    readonly property bool active:
                        !card.extendedForecast
                        && plasmoid.configuration.showHourlyForecast
                        && root.hourlyForecast.length > 0

                    readonly property int capacity:
                        card.width < 370
                        ? 4
                        : (
                            card.width < 430
                            ? 5
                            : 6
                        )

                    // Vertical fit tiers inside the flexible area:
                    // 2 = full, 1 = reduced icon, 0 = compact.
                    readonly property int tier:
                        hourlyArea.height >= 68
                        ? 2
                        : (
                            hourlyArea.height >= 58
                            ? 1
                            : 0
                        )

                    // Ultra-compact: 3 rows (hour, icon, temp + precip).
                    readonly property bool ultra:
                        hourlyArea.height >= 34
                        && hourlyArea.height < 46

                    readonly property int iconSize:
                        tier === 2 ? 26 : (tier === 1 ? 20 : 14)

                    // Fixed line boxes in the reduced tiers so the four
                    // rows stay within the available height.
                    readonly property real hourFont:
                        tier === 2
                        ? Math.max(9, Math.min(12, card.width / 38))
                        : (tier === 1 ? 10 : 9)

                    readonly property real tempFont:
                        tier === 2
                        ? Math.max(10, Math.min(12, card.width / 36))
                        : (tier === 1 ? 10 : 9)

                    readonly property real precipFont:
                        tier === 2
                        ? Math.max(8, Math.min(10, card.width / 43))
                        : (tier === 1 ? 9 : 8)

                    readonly property int lineExtra:
                        tier === 1 ? 3 : 2

                    visible: active && hourlyArea.height >= 34
                    clip: true

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    height: Math.min(68, hourlyArea.height)

                    RowLayout {
                        anchors.fill: parent
                        spacing: 2

                        Repeater {
                            model:
                                Math.min(
                                    hourlyStrip.capacity,
                                    root.hourlyForecast.length
                                )

                            delegate: Item {
                                required property int index

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1

                                readonly property var entry:
                                    root.hourlyForecast[index]

                                ColumnLayout {
                                    visible: !hourlyStrip.ultra

                                    anchors.centerIn: parent
                                    width: parent.width

                                    spacing:
                                        hourlyStrip.tier === 2 ? 1 : 0

                                    PlasmaComponents.Label {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        text:
                                            entry.hour
                                            + " "
                                            + root.tx("hrs", "hrs")

                                        color: theme.hourlyPrimaryText

                                        font.bold: true

                                        font.pixelSize:
                                            hourlyStrip.hourFont

                                        verticalAlignment:
                                            Text.AlignVCenter

                                        Layout.preferredHeight:
                                            hourlyStrip.tier === 2
                                            ? -1
                                            : hourlyStrip.hourFont
                                              + hourlyStrip.lineExtra
                                    }

                                    Kirigami.Icon {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        Layout.preferredWidth:
                                            hourlyStrip.iconSize

                                        Layout.preferredHeight:
                                            Layout.preferredWidth

                                        source:
                                            root.weatherIcon(
                                                entry.code,
                                                entry.isDay
                                            )
                                    }

                                    PlasmaComponents.Label {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        text:
                                            Math.round(
                                                entry.temperature
                                            )
                                            + "°"

                                        color: theme.primaryText

                                        font.pixelSize:
                                            hourlyStrip.tempFont

                                        verticalAlignment:
                                            Text.AlignVCenter

                                        Layout.preferredHeight:
                                            hourlyStrip.tier === 2
                                            ? -1
                                            : hourlyStrip.tempFont
                                              + hourlyStrip.lineExtra
                                    }

                                    PlasmaComponents.Label {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        text:
                                            "☂ "
                                            + (
                                                isFinite(
                                                    entry.precipitation
                                                )
                                                ? Math.round(
                                                    entry.precipitation
                                                ) + "%"
                                                : "--"
                                            )

                                        color: theme.hourlySecondaryText

                                        font.pixelSize:
                                            hourlyStrip.precipFont

                                        verticalAlignment:
                                            Text.AlignVCenter

                                        Layout.preferredHeight:
                                            hourlyStrip.tier === 2
                                            ? -1
                                            : hourlyStrip.precipFont
                                              + hourlyStrip.lineExtra
                                    }
                                }

                                ColumnLayout {
                                    visible: hourlyStrip.ultra

                                    anchors.centerIn: parent
                                    width: parent.width

                                    spacing: 0

                                    PlasmaComponents.Label {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        text:
                                            entry.hour
                                            + " "
                                            + root.tx("hrs", "hrs")

                                        color: theme.hourlyPrimaryText

                                        font.bold: true
                                        font.pixelSize: 9

                                        verticalAlignment:
                                            Text.AlignVCenter

                                        Layout.preferredHeight: 11
                                    }

                                    Kirigami.Icon {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        Layout.preferredWidth: 13
                                        Layout.preferredHeight: 13

                                        source:
                                            root.weatherIcon(
                                                entry.code,
                                                entry.isDay
                                            )
                                    }

                                    RowLayout {
                                        Layout.alignment:
                                            Qt.AlignHCenter

                                        Layout.preferredHeight: 10

                                        spacing: 3

                                        PlasmaComponents.Label {
                                            text:
                                                Math.round(
                                                    entry.temperature
                                                )
                                                + "°"

                                            color: theme.primaryText

                                            font.pixelSize: 9

                                            verticalAlignment:
                                                Text.AlignVCenter
                                        }

                                        PlasmaComponents.Label {
                                            text:
                                                "☂"
                                                + (
                                                    isFinite(
                                                        entry.precipitation
                                                    )
                                                    ? Math.round(
                                                        entry.precipitation
                                                    ) + "%"
                                                    : "--"
                                                )

                                            color: theme.hourlySecondaryText

                                            font.pixelSize: 8

                                            verticalAlignment:
                                                Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.divider
            }

            GridLayout {
                id: forecastGrid

                Layout.fillWidth: true

                Layout.fillHeight:
                    card.extendedForecast

                Layout.preferredHeight:
                    card.extendedForecast
                    ? (
                        card.forecastRows * 82
                        + Math.max(
                              0,
                              card.forecastRows - 1
                          ) * 8
                    )
                    : (
                        card.height >= 320
                        ? 88
                        : 72
                    )

                Layout.minimumHeight:
                    card.extendedForecast
                    ? (
                        card.forecastRows * 78
                        + Math.max(
                              0,
                              card.forecastRows - 1
                          ) * 8
                    )
                    : (
                        card.height >= 320
                        ? 88
                        : 72
                    )

                columns:
                    card.forecastColumns

                columnSpacing: 2
                rowSpacing:
                    card.extendedForecast
                    ? 8
                    : 2

                Repeater {
                    model:
                        Math.min(
                            card.visibleDays,
                            root.forecast.length
                        )

                    delegate: Item {
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Layout.minimumWidth: 38

                        readonly property var day:
                            root.forecast[index]

                        ColumnLayout {
                            anchors.centerIn: parent
                            width: parent.width

                            spacing: 1

                            PlasmaComponents.Label {
                                Layout.alignment:
                                    Qt.AlignHCenter

                                text:
                                    root.forecastDayName(
                                        day.date,
                                        index
                                    )

                                color: theme.dailyPrimaryText

                                font.bold:
                                    index === 0

                                font.pixelSize:
                                    Math.max(
                                        10,
                                        Math.min(
                                            13,
                                            card.width / 36
                                        )
                                    )
                            }

                            PlasmaComponents.Label {
                                Layout.alignment:
                                    Qt.AlignHCenter

                                text:
                                    root.shortDate(
                                        day.date
                                    )

                                color: theme.mutedText

                                font.pixelSize:
                                    Math.max(
                                        8,
                                        Math.min(
                                            10,
                                            card.width / 44
                                        )
                                    )
                            }

                            Kirigami.Icon {
                                Layout.alignment:
                                    Qt.AlignHCenter

                                Layout.preferredWidth:
                                    Math.max(
                                        28,
                                        Math.min(
                                            40,
                                            card.width / 11
                                        )
                                    )

                                Layout.preferredHeight:
                                    Layout.preferredWidth

                                source:
                                    root.weatherIcon(
                                        day.code,
                                        true
                                    )
                            }

                            PlasmaComponents.Label {
                                Layout.alignment:
                                    Qt.AlignHCenter

                                text:
                                    Math.round(
                                        day.max
                                    )
                                    + "° "
                                    + Math.round(
                                        day.min
                                    )
                                    + "°"

                                color: theme.primaryText

                                font.pixelSize:
                                    Math.max(
                                        9,
                                        Math.min(
                                            11,
                                            card.width / 39
                                        )
                                    )
                            }

                            PlasmaComponents.Label {
                                visible:
                                    plasmoid.configuration.showDailyPrecip
                                    && card.height >= 285

                                Layout.alignment:
                                    Qt.AlignHCenter

                                text:
                                    day.precipUnit === "mm"
                                    ? (
                                        "☂ "
                                        + (
                                            isNaN(
                                                root.metricNumber(
                                                    day.precip
                                                )
                                            )
                                            ? "--"
                                            : Number(
                                                day.precip
                                            ).toFixed(1)
                                              + " mm"
                                        )
                                    )
                                    : (
                                        "☂ "
                                        + root.percentText(
                                            day.precip
                                        )
                                    )

                                color: theme.dailySecondaryText

                                font.pixelSize:
                                    Math.max(
                                        8,
                                        Math.min(
                                            10,
                                            card.width / 43
                                        )
                                    )
                            }
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                visible:
                    root.errorText !== ""

                Layout.fillWidth: true

                horizontalAlignment:
                    Text.AlignHCenter

                text: root.errorText

                color: "#ffffb4b4"

                wrapMode:
                    Text.WordWrap
            }
        }
    }
}
