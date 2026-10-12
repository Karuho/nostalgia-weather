import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../code/Timezones.js" as Timezones
import "../code/Translations.js" as I18n

Item {
    id: page

    implicitWidth: 700
    implicitHeight: 700

    property string title:
        tx("General", "General")

    property alias cfg_locationName:
        locationName.text

    property alias cfg_latitude:
        latitude.text

    property alias cfg_longitude:
        longitude.text

    property string cfg_timezone:
        "America/Santiago"

    property string cfg_language:
        "en"

    property string cfg_temperatureUnit:
        "celsius"

    property int cfg_forecastDays:
        7

    property alias cfg_updateMinutes:
        updateMinutes.value

    property alias cfg_showDate:
        showDate.checked

    property alias cfg_showFeelsLike:
        showFeelsLike.checked

    property alias cfg_showPrecipitation:
        showPrecipitation.checked

    property alias cfg_showUv:
        showUv.checked

    property alias cfg_showSun:
        showSun.checked

    property alias cfg_showAirQuality:
        showAirQuality.checked

    property alias cfg_showDust:
        showDust.checked

    property alias cfg_showMoon:
        showMoon.checked

    property alias cfg_showDailyPrecip:
        showDailyPrecip.checked

    /*
     * Compatibilidad con configuraciones 0.2.0–0.2.2.
     * Ya no aparecen en la UI ni controlan los botones.
     */
    property bool cfg_showConfigButton: true
    property bool cfg_showRefreshButton: true

    property string cfg_locationNameDefault: ""
    property string cfg_latitudeDefault: ""
    property string cfg_longitudeDefault: ""

    property string cfg_timezoneDefault:
        "America/Santiago"

    property string cfg_languageDefault:
        "en"

    property string cfg_temperatureUnitDefault:
        "celsius"

    property int cfg_updateMinutesDefault: 30
    property int cfg_forecastDaysDefault: 7

    property bool cfg_showDateDefault: true
    property bool cfg_showFeelsLikeDefault: true
    property bool cfg_showPrecipitationDefault: true
    property bool cfg_showUvDefault: true
    property bool cfg_showSunDefault: true
    property bool cfg_showAirQualityDefault: true
    property bool cfg_showDustDefault: true
    property bool cfg_showMoonDefault: true
    property bool cfg_showDailyPrecipDefault: true

    property bool cfg_showConfigButtonDefault: true
    property bool cfg_showRefreshButtonDefault: true

    property var searchResults: []

    property bool searching: false
    property bool resultsVisible: false

    property bool locatingCurrent: false
    property string currentLocationMessage: ""

    property string searchError: ""

    /*
     * Evita que una respuesta vieja ("Re")
     * reemplace los resultados de una búsqueda
     * nueva ("Rengo").
     */
    property int searchSerial: 0

    /*
     * Estado de la resolución de "Usar ubicación actual".
     * currentSerial descarta respuestas de una solicitud anterior.
     */
    property int currentSerial: 0
    property bool currentResolving: false
    property bool currentTimezoneDone: false
    property bool currentPlaceDone: false
    property string currentTimezone: ""
    property string currentPlace: ""
    property real currentLat: 0
    property real currentLon: 0

    readonly property var dayValues: [
        3,
        5,
        7,
        10,
        16,
        30
    ]

    function tx(en, es) {
        return I18n.t(
            cfg_language,
            en,
            es
        )
    }

    function resultLabel(result) {
        var parts = [result.name]

        if (result.admin1
                && result.admin1 !== result.name) {
            parts.push(result.admin1)
        }

        if (result.country)
            parts.push(result.country)

        return parts.join(", ")
    }

    function selectLocation(result) {
        locationName.text =
            result.label

        latitude.text =
            Number(
                result.latitude
            ).toFixed(6)

        longitude.text =
            Number(
                result.longitude
            ).toFixed(6)

        /*
         * La zona horaria viene de la ciudad elegida.
         * Ej:
         * Rengo        -> America/Santiago
         * Punta Arenas -> America/Punta_Arenas
         * Rapa Nui     -> Pacific/Easter
         */
        cfg_timezone =
            result.timezone
            || "UTC"

        locationSearch.text =
            result.label

        searchResults = []
        resultsVisible = false
        searchError = ""

        ++searchSerial
    }

    function locationFailure(reason) {
        locatingCurrent = false

        if (reason === "access") {
            currentLocationMessage =
                tx(
                    "Location access was denied.",
                    "Se denegó el acceso a la ubicación."
                )
            return
        }

        if (reason === "timeout") {
            currentLocationMessage =
                tx(
                    "Location request timed out.",
                    "Se agotó el tiempo para obtener la ubicación."
                )
            return
        }

        currentLocationMessage =
            tx(
                "Location services are unavailable.",
                "Los servicios de ubicación no están disponibles."
            )
    }

    function joinUnique(values) {
        var parts = []

        for (var v = 0; v < values.length; ++v) {
            var value = values[v]

            if (!value)
                continue

            var duplicate = false

            for (var i = 0; i < parts.length; ++i) {
                if (parts[i] === value) {
                    duplicate = true
                    break
                }
            }

            if (!duplicate)
                parts.push(value)
        }

        return parts.join(", ")
    }

    /*
     * Returns "" when no human-readable place can be built;
     * the caller decides on the localized final fallback.
     */
    function detectedPlaceLabel(properties) {
        if (!properties)
            return ""

        var primary =
            properties.city
            || properties.locality
            || properties.district
            || properties.county
            || properties.name
            || ""

        return joinUnique([
            primary,
            properties.state || "",
            properties.country || ""
        ])
    }

    function bigDataCloudPlaceLabel(data) {
        if (!data)
            return ""

        /*
         * Prefer city over locality to avoid overly granular
         * suburb names.
         */
        var settlement =
            data.city
            || data.locality
            || ""

        return joinUnique([
            settlement,
            data.principalSubdivision || "",
            data.countryName || ""
        ])
    }

    function applyDetectedLocation(
        lat,
        lon,
        timezone,
        label
    ) {
        latitude.text =
            Number(lat).toFixed(6)

        longitude.text =
            Number(lon).toFixed(6)

        /*
         * Keep the current time zone if it could not be resolved.
         */
        if (timezone)
            cfg_timezone = timezone

        locationName.text =
            label

        locationSearch.text =
            label

        searchResults = []
        resultsVisible = false
        searchError = ""

        locatingCurrent = false

        if (timezone) {
            currentLocationMessage =
                tx(
                    "Location detected. Press Apply to save it.",
                    "Ubicación detectada. Pulsa Aplicar para guardarla."
                )
        } else {
            currentLocationMessage =
                tx(
                    "Could not determine the current time zone.",
                    "No se pudo determinar la zona horaria actual."
                )
        }
    }

    /*
     * Current-location resolution. The place name and the time
     * zone are requested independently and combined here once
     * both have completed (or the watchdog fires). currentSerial
     * discards replies belonging to an older request.
     */
    function startCurrentResolution(lat, lon) {
        var serial = ++currentSerial

        currentResolving = true
        currentTimezoneDone = false
        currentPlaceDone = false
        currentTimezone = ""
        currentPlace = ""
        currentLat = lat
        currentLon = lon

        currentResolveTimer.restart()

        resolveCurrentTimezone(serial, lat, lon)
        reverseCurrentLocation(serial, lat, lon)
    }

    function maybeFinishCurrent(serial, force) {
        if (serial !== currentSerial || !currentResolving)
            return

        if (!force
                && !(currentTimezoneDone && currentPlaceDone)) {
            return
        }

        currentResolving = false
        currentResolveTimer.stop()

        var label = currentPlace

        if (!label) {
            label = tx(
                "Current location",
                "Ubicación actual"
            )
        }

        applyDetectedLocation(
            currentLat,
            currentLon,
            currentTimezone,
            label
        )
    }

    function completeCurrentTimezone(serial, timezone) {
        if (serial !== currentSerial
                || !currentResolving
                || currentTimezoneDone) {
            return
        }

        currentTimezoneDone = true
        currentTimezone = timezone || ""

        maybeFinishCurrent(serial, false)
    }

    function completeCurrentPlace(serial, label) {
        if (serial !== currentSerial
                || !currentResolving
                || currentPlaceDone) {
            return
        }

        currentPlaceDone = true
        currentPlace = label || ""

        maybeFinishCurrent(serial, false)
    }

    /*
     * GET a JSON document. callback receives the parsed data,
     * or null on any HTTP/network/parse failure; it is called
     * exactly once.
     */
    function fetchJson(url, callback) {
        var request =
            new XMLHttpRequest()

        request.onreadystatechange =
            function() {

            if (request.readyState !== 4)
                return

            if (request.status !== 200) {
                console.log(
                    "Nostalgia Weather HTTP error:",
                    request.status,
                    url
                )

                callback(null)
                return
            }

            var data = null

            try {
                data = JSON.parse(
                    request.responseText
                )
            } catch (e) {
                console.log(
                    "Nostalgia Weather parse error:",
                    e
                )
            }

            callback(data)
        }

        request.open(
            "GET",
            url
        )

        request.send()
    }

    function reverseCurrentLocation(
        serial,
        lat,
        lon
    ) {
        var language =
            I18n.geocodingLanguage(
                cfg_language
            )

        var url =
            "https://photon.komoot.io/reverse"
            + "?lat="
            + encodeURIComponent(lat)
            + "&lon="
            + encodeURIComponent(lon)
            + "&limit=1"
            + "&lang="
            + encodeURIComponent(language)

        fetchJson(url, function(data) {
            if (serial !== currentSerial || !currentResolving)
                return

            var label = ""

            if (data
                    && data.features
                    && data.features.length > 0) {
                label = detectedPlaceLabel(
                    data.features[0].properties
                )
            }

            if (label) {
                completeCurrentPlace(serial, label)
                return
            }

            /*
             * Photon failed or returned nothing:
             * one fallback request, only for this explicit action.
             */
            reverseCurrentLocationBigDataCloud(
                serial,
                lat,
                lon,
                language
            )
        })
    }

    /*
     * BigDataCloud free client-side reverse geocoder. Valid only
     * for coordinates obtained with user consent on this same
     * device, which is exactly the explicit current-location flow.
     */
    function reverseCurrentLocationBigDataCloud(
        serial,
        lat,
        lon,
        language
    ) {
        if (serial !== currentSerial || !currentResolving)
            return

        var url =
            "https://api.bigdatacloud.net/data/reverse-geocode-client"
            + "?latitude="
            + encodeURIComponent(lat)
            + "&longitude="
            + encodeURIComponent(lon)
            + "&localityLanguage="
            + encodeURIComponent(language)

        fetchJson(url, function(data) {
            completeCurrentPlace(
                serial,
                bigDataCloudPlaceLabel(data)
            )
        })
    }

    function resolveCurrentTimezone(
        serial,
        lat,
        lon
    ) {
        var url =
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude="
            + encodeURIComponent(lat)
            + "&longitude="
            + encodeURIComponent(lon)
            + "&current=temperature_2m"
            + "&timezone=auto"
            + "&forecast_days=1"

        fetchJson(url, function(data) {
            completeCurrentTimezone(
                serial,
                data && data.timezone
                    ? data.timezone
                    : ""
            )
        })
    }



    function searchLocations() {
        var query =
            locationSearch.text.trim()

        if (query.length < 3) {
            searchResults = []
            resultsVisible = false
            searchError = ""
            return
        }

        var mySerial =
            ++searchSerial

        searching = true
        searchError = ""

        var url =
            "https://geocoding-api.open-meteo.com/v1/search"
            + "?name="
            + encodeURIComponent(query)
            + "&count=8"
            + "&language="
            + encodeURIComponent(
                I18n.geocodingLanguage(
                    cfg_language
                )
            )
            + "&format=json"

        var request =
            new XMLHttpRequest()

        request.onreadystatechange =
            function() {

            if (request.readyState !== 4)
                return

            /*
             * Ignorar respuestas de búsquedas antiguas.
             */
            if (mySerial !== searchSerial)
                return

            if (query
                    !== locationSearch.text.trim()) {
                return
            }

            searching = false

            if (request.status !== 200) {
                searchResults = []
                resultsVisible = false

                searchError =
                    tx(
                        "Location search failed.",
                        "No se pudo buscar la ubicación."
                    )

                return
            }

            try {
                var data =
                    JSON.parse(
                        request.responseText
                    )

                var raw =
                    data.results || []

                var results = []

                for (
                    var i = 0;
                    i < raw.length;
                    ++i
                ) {
                    var item =
                        raw[i]

                    results.push({
                        label:
                            resultLabel(item),

                        name:
                            item.name,

                        admin1:
                            item.admin1 || "",

                        country:
                            item.country || "",

                        latitude:
                            item.latitude,

                        longitude:
                            item.longitude,

                        timezone:
                            item.timezone || "UTC"
                    })
                }

                searchResults =
                    results

                resultsVisible =
                    results.length > 0

                if (results.length === 0) {
                    searchError =
                        tx(
                            "No locations found.",
                            "No se encontraron ubicaciones."
                        )
                }

            } catch (e) {
                searchResults = []
                resultsVisible = false

                searchError =
                    tx(
                        "Invalid location response.",
                        "La respuesta de ubicación no es válida."
                    )

                console.log(
                    "Nostalgia Weather geocoding:",
                    e
                )
            }
        }

        request.open(
            "GET",
            url
        )

        request.send()
    }

    Timer {
        id: searchTimer

        interval: 400
        repeat: false

        onTriggered:
            page.searchLocations()
    }

    /*
     * Watchdog: never leave the UI busy if a request hangs.
     * Applies whatever has been resolved so far.
     */
    Timer {
        id: currentResolveTimer

        interval: 25000
        repeat: false

        onTriggered:
            page.maybeFinishCurrent(
                page.currentSerial,
                true
            )
    }

    Component.onCompleted: {
        locationSearch.text =
            locationName.text
    }

    CurrentLocation {
        id: currentLocation

        onPositionReady:
            function(latitudeValue, longitudeValue, accuracy) {

            page.startCurrentResolution(
                latitudeValue,
                longitudeValue
            )
        }

        onPositionFailed:
            function(reason) {

            page.locationFailure(
                reason
            )
        }
    }

    Flickable {
        anchors.fill: parent

        contentWidth:
            width

        contentHeight:
            form.implicitHeight + 32

        clip: true

        boundsBehavior:
            Flickable.StopAtBounds

        QQC2.ScrollBar.vertical:
            QQC2.ScrollBar {}

        Kirigami.FormLayout {
            id: form

            width:
                Math.max(
                    320,
                    parent.width - 28
                )

            y: 8

            QQC2.Label {
                Kirigami.FormData.isSection:
                    true

                text:
                    page.tx(
                        "Location",
                        "Ubicación"
                    )
            }

            ColumnLayout {
                Kirigami.FormData.label:
                    page.tx(
                        "Search:",
                        "Buscar:"
                    )

                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    QQC2.TextField {
                        id: locationSearch

                        Layout.fillWidth: true

                        placeholderText:
                            page.tx(
                                "City, region or postal code",
                                "Ciudad, región o código postal"
                            )

                        selectByMouse: true

                        onTextEdited: {
                            ++page.searchSerial

                            page.searchError = ""

                            if (
                                text.trim().length >= 3
                            ) {
                                searchTimer.restart()
                            } else {
                                searchTimer.stop()

                                page.searchResults = []
                                page.resultsVisible = false
                            }
                        }

                        onAccepted:
                            page.searchLocations()
                    }

                    QQC2.BusyIndicator {
                        running:
                            page.searching

                        visible:
                            page.searching

                        implicitWidth: 26
                        implicitHeight: 26
                    }
                }

                QQC2.Frame {
                    visible:
                        page.resultsVisible
                        && page.searchResults.length > 0

                    Layout.fillWidth: true

                    padding: 2

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        Repeater {
                            model:
                                Math.min(
                                    8,
                                    page.searchResults.length
                                )

                            delegate:
                                QQC2.ItemDelegate {
                                id: resultDelegate

                                required property int index

                                Layout.fillWidth: true
                                Layout.maximumWidth:
                                    parent.width

                                implicitWidth: 0

                                text:
                                    page.searchResults[
                                        index
                                    ].label

                                contentItem:
                                    QQC2.Label {
                                    text:
                                        resultDelegate.text

                                    elide:
                                        Text.ElideRight

                                    maximumLineCount: 1

                                    verticalAlignment:
                                        Text.AlignVCenter
                                }

                                onClicked:
                                    page.selectLocation(
                                        page.searchResults[
                                            index
                                        ]
                                    )
                            }
                        }
                    }
                }

                QQC2.Label {
                    visible:
                        page.searchError !== ""

                    Layout.fillWidth: true

                    text:
                        page.searchError

                    wrapMode:
                        Text.WordWrap

                    color:
                        Kirigami.Theme
                            .negativeTextColor
                }
            }

            RowLayout {
                Layout.fillWidth: true

                QQC2.Button {
                    text:
                        page.tx(
                            "Use current location",
                            "Usar ubicación actual"
                        )

                    icon.name:
                        "mark-location"

                    enabled:
                        !page.locatingCurrent

                    onClicked: {
                        page.currentLocationMessage =
                            page.tx(
                                "Detecting current location…",
                                "Detectando ubicación actual…"
                            )

                        page.locatingCurrent = true

                        currentLocation.request()
                    }
                }

                QQC2.BusyIndicator {
                    running:
                        page.locatingCurrent

                    visible:
                        page.locatingCurrent

                    implicitWidth: 26
                    implicitHeight: 26
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            QQC2.Label {
                visible:
                    page.currentLocationMessage !== ""

                Layout.fillWidth: true

                text:
                    page.currentLocationMessage

                wrapMode:
                    Text.WordWrap

                color:
                    Kirigami.Theme.disabledTextColor
            }

            QQC2.TextField {
                id: locationName

                Kirigami.FormData.label:
                    page.tx(
                        "Selected location:",
                        "Ubicación seleccionada:"
                    )

                Layout.fillWidth: true
            }

            QQC2.TextField {
                id: latitude

                Kirigami.FormData.label:
                    page.tx(
                        "Latitude:",
                        "Latitud:"
                    )

                Layout.fillWidth: true
            }

            QQC2.TextField {
                id: longitude

                Kirigami.FormData.label:
                    page.tx(
                        "Longitude:",
                        "Longitud:"
                    )

                Layout.fillWidth: true
            }

            QQC2.ComboBox {
                id: timezoneCombo

                Kirigami.FormData.label:
                    page.tx(
                        "Time zone:",
                        "Zona horaria:"
                    )

                Layout.fillWidth: true

                editable: false

                model:
                    Timezones.zones

                currentIndex: {
                    var index =
                        Timezones.zones.indexOf(
                            page.cfg_timezone
                        )

                    if (index >= 0)
                        return index

                    return Timezones.zones.indexOf(
                        "UTC"
                    )
                }

                onActivated:
                    page.cfg_timezone =
                        currentText
            }

            QQC2.Label {
                Kirigami.FormData.isSection:
                    true

                text:
                    page.tx(
                        "Forecast",
                        "Pronóstico"
                    )
            }

            QQC2.ComboBox {
                Kirigami.FormData.label:
                    page.tx(
                        "Days to show:",
                        "Días a mostrar:"
                    )

                model: [
                    page.tx("3 days", "3 días"),
                    page.tx("5 days", "5 días"),
                    page.tx("7 days", "7 días"),
                    page.tx("10 days", "10 días"),
                    page.tx("16 days", "16 días"),
                    page.tx("30 days", "30 días")
                ]

                currentIndex:
                    Math.max(
                        0,
                        page.dayValues.indexOf(
                            page.cfg_forecastDays
                        )
                    )

                onActivated:
                    page.cfg_forecastDays =
                        page.dayValues[
                            currentIndex
                        ]
            }

            QQC2.ComboBox {
                Kirigami.FormData.label:
                    page.tx(
                        "Temperature:",
                        "Temperatura:"
                    )

                model: [
                    "Celsius (°C)",
                    "Fahrenheit (°F)"
                ]

                currentIndex:
                    page.cfg_temperatureUnit
                        === "fahrenheit"
                    ? 1
                    : 0

                onActivated:
                    page.cfg_temperatureUnit =
                        currentIndex === 1
                        ? "fahrenheit"
                        : "celsius"
            }

            QQC2.SpinBox {
                id: updateMinutes

                Kirigami.FormData.label:
                    page.tx(
                        "Update every:",
                        "Actualizar cada:"
                    )

                from: 10
                to: 180
                stepSize: 5

                editable: true

                textFromValue:
                    function(value) {
                        return value
                            + " min"
                    }

                valueFromText:
                    function(text) {
                        return parseInt(text)
                    }
            }

            QQC2.Label {
                Kirigami.FormData.isSection:
                    true

                text:
                    page.tx(
                        "Language",
                        "Idioma"
                    )
            }

            QQC2.ComboBox {
                Kirigami.FormData.label:
                    page.tx(
                        "Interface language:",
                        "Idioma de la interfaz:"
                    )

                model:
                    I18n.languageNames

                currentIndex:
                    Math.max(
                        0,
                        I18n.languageCodes.indexOf(
                            page.cfg_language
                        )
                    )

                onActivated: {
                    page.cfg_language =
                        I18n.languageCodes[
                            currentIndex
                        ]

                    ++page.searchSerial

                    page.searchResults = []
                    page.resultsVisible = false
                }
            }

            QQC2.Label {
                text:
                    page.tx(
                        "English is the default language.",
                        "El inglés es el idioma predeterminado."
                    )

                color:
                    Kirigami.Theme
                        .disabledTextColor
            }

            QQC2.Label {
                Kirigami.FormData.isSection:
                    true

                text:
                    page.tx(
                        "Visible information",
                        "Información visible"
                    )
            }

            QQC2.CheckBox {
                id: showDate

                text:
                    page.tx(
                        "Date",
                        "Fecha"
                    )
            }

            QQC2.CheckBox {
                id: showFeelsLike

                text:
                    page.tx(
                        "Feels-like temperature",
                        "Sensación térmica"
                    )
            }

            QQC2.CheckBox {
                id: showPrecipitation

                text:
                    page.tx(
                        "Precipitation probability",
                        "Probabilidad de precipitación"
                    )
            }

            QQC2.CheckBox {
                id: showUv

                text:
                    page.tx(
                        "UV index",
                        "Índice UV"
                    )
            }

            QQC2.CheckBox {
                id: showSun

                text:
                    page.tx(
                        "Sunrise and sunset",
                        "Amanecer y atardecer"
                    )
            }

            QQC2.CheckBox {
                id: showAirQuality

                text:
                    page.tx(
                        "Air quality",
                        "Calidad del aire"
                    )
            }

            QQC2.CheckBox {
                id: showDust

                text:
                    page.tx(
                        "Atmospheric dust",
                        "Polvo atmosférico"
                    )
            }

            QQC2.CheckBox {
                id: showMoon

                text:
                    page.tx(
                        "Moon phase",
                        "Fase lunar"
                    )
            }

            QQC2.CheckBox {
                id: showDailyPrecip

                text:
                    page.tx(
                        "Daily precipitation below forecast",
                        "Precipitación diaria bajo el pronóstico"
                    )
            }

            Item {
                implicitHeight: 20
            }
        }
    }
}
