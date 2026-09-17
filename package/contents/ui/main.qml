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

    readonly property var today:
        forecast.length > 0 ? forecast[0] : null

    property real currentAqi: NaN
    property real currentDust: NaN
    property real currentPm25: NaN

    property bool loading: false
    property string errorText: ""

    readonly property string locationName:
        plasmoid.configuration.locationName || tx(
            "Location",
            "Ubicación"
        )

    readonly property string uiLanguage:
        plasmoid.configuration.language || "en"

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

    function tx(en, es) {
        return I18n.t(
            uiLanguage,
            en,
            es
        )
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

    function refreshAirQuality(lat, lon) {
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

    function refreshWeather() {
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
            errorText = tx("Invalid coordinates", "Coordenadas inválidas")
            return
        }

        loading = true
        errorText = ""

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
            + "&temperature_unit="
            + encodeURIComponent(
                root.temperatureUnit
            )
            + "&timezone="
            + encodeURIComponent(
                plasmoid.configuration.timezone
                || "auto"
            )
            + "&forecast_days="
            + Math.max(
                3,
                Math.min(
                    16,
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

            loading = false

            if (request.status !== 200) {
                errorText =
                    tx(
                        "Unable to update weather",
                        "No se pudo actualizar el clima"
                    )

                console.log(
                    "Nostalgia Weather weather HTTP error:",
                    request.status,
                    request.responseText
                )

                return
            }

            try {
                var data = JSON.parse(
                    request.responseText
                )

                currentTemperature =
                    data.current.temperature_2m

                apparentTemperature =
                    data.current.apparent_temperature

                currentCode =
                    data.current.weather_code

                currentIsDay =
                    data.current.is_day === 1

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

                forecast = days
                errorText = ""

                refreshAirQuality(lat, lon)

            } catch (e) {
                errorText =
                    i18n(
                        "Respuesta meteorológica inválida"
                    )

                console.log(
                    "Nostalgia Weather parse error:",
                    e
                )
            }
        }

        request.open("GET", url)
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

    Component.onCompleted:
        refreshWeather()

    onTemperatureUnitChanged:
        configurationRefreshTimer.restart()


    onConfiguredLatitudeChanged:
        configurationRefreshTimer.restart()

    onConfiguredLongitudeChanged:
        configurationRefreshTimer.restart()

    onConfiguredTimezoneChanged:
        configurationRefreshTimer.restart()

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
                    16,
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
                    : 16
                )
            )

        readonly property int visibleDays:
            Math.min(
                requestedDays,
                adaptiveCapacity
            )

        readonly property bool extendedForecast:
            visibleDays > 7

        readonly property int forecastColumns:
            visibleDays <= 7
            ? Math.max(1, visibleDays)
            : (
                visibleDays <= 10
                ? 5
                : 8
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
            border.color: "#80ffffff"

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#c05a6a78"
                }

                GradientStop {
                    position: 0.42
                    color: "#c0334352"
                }

                GradientStop {
                    position: 1.0
                    color: "#dc15232f"
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

            color: "#18ffffff"
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

                    color: "#e8ffffff"

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

                        color: "white"

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

                        color: "#e4ffffff"

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

                        color: "#bfffffff"
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

                    color: "white"

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
                                    Math.round(
                                        root.today.precip
                                    ) + "%",
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
                                    "UV "
                                    + Number(
                                        root.today.uv
                                    ).toFixed(1),
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

                                color: "#f0ffffff"

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

                                color: "#eaffffff"

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
                Layout.fillHeight:
                    !card.extendedForecast

                Layout.minimumHeight: 0
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#45ffffff"
            }

            GridLayout {
                id: forecastGrid

                Layout.fillWidth: true

                Layout.fillHeight:
                    card.extendedForecast

                Layout.preferredHeight:
                    card.extendedForecast
                    ? 170
                    : (
                        card.height >= 320
                        ? 88
                        : 72
                    )

                Layout.minimumHeight:
                    card.extendedForecast
                    ? 164
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

                                color: "#efffffff"

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

                                color: "#bfffffff"

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

                                color: "white"

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
                                    "☂ "
                                    + Math.round(
                                        day.precip
                                    )
                                    + "%"

                                color: "#cfffffff"

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
