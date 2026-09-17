import QtQuick
import QtPositioning

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property bool busy: false

    signal positionReady(
        real latitude,
        real longitude
    )

    signal positionFailed(
        string reason
    )

    function fail(reason) {
        if (!busy)
            return

        busy = false
        guard.stop()

        positionFailed(reason)
    }

    function request() {
        if (busy)
            return

        if (!source.valid) {
            positionFailed("unavailable")
            return
        }

        busy = true

        guard.restart()

        /*
         * One-shot position request.
         * No continuous tracking.
         */
        source.update(15000)
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
                    || !isFinite(lon)) {
                root.fail("invalid")
                return
            }

            root.busy = false
            guard.stop()

            root.positionReady(
                lat,
                lon
            )
        }

        onSourceErrorChanged: {
            if (!root.busy)
                return

            if (sourceError
                    === PositionSource.NoError) {
                return
            }

            if (sourceError
                    === PositionSource.AccessError) {
                root.fail("access")
                return
            }

            if (sourceError
                    === PositionSource.ClosedError) {
                root.fail("closed")
                return
            }

            if (sourceError
                    === PositionSource.UpdateTimeoutError) {
                root.fail("timeout")
                return
            }

            root.fail("unknown")
        }
    }

    Timer {
        id: guard

        interval: 17000
        repeat: false

        onTriggered:
            root.fail("timeout")
    }
}
