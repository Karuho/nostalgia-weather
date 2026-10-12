import QtQuick
import QtPositioning

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property bool busy: false

    /*
     * Bounded sampling window. GeoClue's first fix is often a
     * coarse IP/WiFi fallback; improved fixes can arrive many
     * seconds later, so the source is left running briefly and
     * then stopped explicitly.
     */
    readonly property int sampleWindowMs: 19000

    /*
     * A fix at least this precise (meters) ends sampling early.
     */
    readonly property real goodAccuracyMeters: 100

    /*
     * Best fix seen during the current sampling window.
     * accuracy is -1 when the backend did not report one.
     */
    property bool haveFix: false
    property real fixLatitude: 0
    property real fixLongitude: 0
    property real fixAccuracy: -1

    signal positionReady(
        real latitude,
        real longitude,
        real accuracy
    )

    signal positionFailed(
        string reason
    )

    function stopSampling() {
        sampleTimer.stop()

        if (source.active)
            source.stop()
    }

    function fail(reason) {
        if (!busy)
            return

        busy = false
        stopSampling()

        positionFailed(reason)
    }

    function finish() {
        if (!busy)
            return

        if (!haveFix) {
            fail("timeout")
            return
        }

        busy = false
        stopSampling()

        positionReady(
            fixLatitude,
            fixLongitude,
            fixAccuracy
        )
    }

    function acceptFix(lat, lon, accuracy) {
        /*
         * Observed GeoClue fixes can report the same accuracy
         * while the coordinates improve, so later fixes win.
         * The only fixes ignored are ones that explicitly report
         * a much worse accuracy than the fix already kept.
         */
        if (haveFix
                && accuracy >= 0
                && fixAccuracy >= 0
                && accuracy > fixAccuracy * 2) {
            return
        }

        haveFix = true
        fixLatitude = lat
        fixLongitude = lon
        fixAccuracy = accuracy
    }

    function request() {
        if (busy)
            return

        if (!source.valid) {
            positionFailed("unavailable")
            return
        }

        haveFix = false
        fixAccuracy = -1

        busy = true

        sampleTimer.restart()

        /*
         * Updates run only for this bounded window and are
         * stopped in finish()/fail(). No background tracking.
         */
        source.start()
    }

    PositionSource {
        id: source

        name: "geoclue2"

        onPositionChanged: {
            if (!root.busy)
                return

            var coordinate =
                position.coordinate

            var lat =
                coordinate.latitude

            var lon =
                coordinate.longitude

            if (!isFinite(lat)
                    || !isFinite(lon)
                    || Math.abs(lat) > 90
                    || Math.abs(lon) > 180) {
                return
            }

            var accuracy = -1

            if (position.horizontalAccuracyValid
                    && isFinite(position.horizontalAccuracy)
                    && position.horizontalAccuracy >= 0) {
                accuracy =
                    position.horizontalAccuracy
            }

            root.acceptFix(
                lat,
                lon,
                accuracy
            )

            if (accuracy >= 0
                    && accuracy <= root.goodAccuracyMeters) {
                root.finish()
            }
        }

        onSourceErrorChanged: {
            if (!root.busy)
                return

            if (sourceError
                    === PositionSource.NoError) {
                return
            }

            /*
             * UpdateTimeoutError is not terminal for regular
             * updates: later fixes may still arrive. sampleTimer
             * alone bounds the sampling window.
             */
            if (sourceError
                    === PositionSource.UpdateTimeoutError) {
                return
            }

            if (sourceError
                    === PositionSource.AccessError) {
                root.fail("access")
                return
            }

            /*
             * Once a valid fix exists, sampleTimer owns completion.
             * Do not finish early: a better fix may still arrive,
             * and at worst the timer uses the last valid one.
             */
            if (root.haveFix)
                return

            if (sourceError
                    === PositionSource.ClosedError) {
                root.fail("closed")
                return
            }

            root.fail("unknown")
        }
    }

    Timer {
        id: sampleTimer

        interval: root.sampleWindowMs
        repeat: false

        onTriggered:
            root.finish()
    }
}
