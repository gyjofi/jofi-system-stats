import QtQuick

import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.battery as Battery
import QtQuick.Layouts

PlasmoidItem {
    id: root
    property string batterySensorBase: ""

    function formatSpeed(bytesPerSecond) {
        if (bytesPerSecond >= 1024 * 1024 * 1024) {
            return (bytesPerSecond / (1024 * 1024 * 1024)).toFixed(1) + "G"
        }

        if (bytesPerSecond >= 1024 * 1024) {
            return (bytesPerSecond / (1024 * 1024)).toFixed(1) + "M"
        }

        if (bytesPerSecond >= 1024) {
            return Math.round(bytesPerSecond / 1024) + "K"
        }

        return Math.round(bytesPerSecond) + "B"
    }

    function batteryColor() {
        const battery = Number(batterySensor.value)

        if (battery <= Plasmoid.configuration.batteryCritical) {
            return Kirigami.Theme.negativeTextColor
        }

        if (battery <= Plasmoid.configuration.batteryWarning) {
            return Kirigami.Theme.neutralTextColor
        }

        return Kirigami.Theme.positiveTextColor
    }

    function batteryText() {
        if (root.batterySensorBase.length === 0) return ""

        const battery = Math.round(Number(batterySensor.value))
        const charging =
            batteryControl.state === Battery.BatteryControlModel.Charging

        return "BAT " + (charging ? "⚡" : "") + battery + "%"
    }

    function batteryIsCritical() {
        if (root.batterySensorBase.length === 0) return false

        const battery = Number(batterySensor.value)
        const charging =
            batteryControl.state === Battery.BatteryControlModel.Charging

        return !charging
            && battery <= Plasmoid.configuration.batteryCritical
    }

    function findBatterySensor() {
        for (let row = 0; row < flatSensorModel.rowCount(); ++row) {
            const index = flatSensorModel.index(row, 0)

            const sensorId = flatSensorModel.data(
                index,
                Sensors.SensorTreeModel.SensorId
            )

            if (!sensorId) {
                continue
            }

            // Csak konkrét power/<id>/chargePercentage sensor kell.
            // A KSystemStats fában vannak wildcard/regex bejegyzések is,
            // pl. power/(?!all).*/chargePercentage.
            const match = sensorId.match(
                /^power\/([^/*()?!]+)\/chargePercentage$/
            )

            if (match) {
                return sensorId
            }
        }

        return ""
    }

    function statsText() {
        const parts = []

        if (Plasmoid.configuration.showCpu) {
            parts.push("CPU " + Math.round(cpuSensor.value) + "%")
        }

        if (Plasmoid.configuration.showRam) {
            parts.push("RAM " + Math.round(ramSensor.value) + "%")
        }

        if (Plasmoid.configuration.showTemperature) {
            parts.push(Math.round(cpuTempSensor.value) + "°C")
        }

        if (Plasmoid.configuration.showDownload) {
            parts.push("↓ " + formatSpeed(downloadSensor.value))
        }

        if (Plasmoid.configuration.showUpload) {
            parts.push("↑ " + formatSpeed(uploadSensor.value))
        }

        const separator = Plasmoid.configuration.separator

        return parts.join(
            separator.length > 0
                ? " " + separator + " "
                : " "
        )
    }

    Battery.BatteryControlModel {
        id: batteryControl
    }

    Sensors.SensorTreeModel {
        id: sensorTreeModel
    }

    KItemModels.KDescendantsProxyModel {
        id: flatSensorModel
        model: sensorTreeModel
    }

    Sensors.Sensor {
        id: cpuSensor
        sensorId: "cpu/all/usage"
        updateRateLimit: Plasmoid.configuration.updateInterval
    }

    Sensors.Sensor {
        id: ramSensor
        sensorId: "memory/physical/usedPercent"
        updateRateLimit: Plasmoid.configuration.updateInterval
    }

    Sensors.Sensor {
        id: cpuTempSensor
        sensorId: "cpu/all/averageTemperature"
        updateRateLimit: Plasmoid.configuration.updateInterval
    }

    Sensors.Sensor {
        id: downloadSensor
        sensorId: "network/all/download"
        updateRateLimit: Plasmoid.configuration.updateInterval
    }

    Sensors.Sensor {
        id: uploadSensor
        sensorId: "network/all/upload"
        updateRateLimit: Plasmoid.configuration.updateInterval
    }

    Sensors.Sensor {
        id: batterySensor

        sensorId: root.batterySensorBase.length > 0
            ? root.batterySensorBase + "/chargePercentage"
            : ""

        updateRateLimit: Plasmoid.configuration.updateInterval
    }

    Timer {
        id: batteryDiscoveryTimer

        interval: 500
        running: true
        repeat: true

        onTriggered: {
            if (flatSensorModel.rowCount() === 0) {
                return
            }

            const sensorId = root.findBatterySensor()

            if (sensorId.length > 0) {
                root.batterySensorBase =
                    sensorId.substring(
                        0,
                        sensorId.length - "/chargePercentage".length
                    )

                stop()
            }
        }
    }

    compactRepresentation: Rectangle {
        id: compactRoot

        color: "transparent"

        border.width: Plasmoid.configuration.batteryCriticalBorder
                    && Plasmoid.configuration.showBattery
                    && root.batterySensorBase.length > 0
                    && root.batteryIsCritical()
                    ? 1
                    : 0

        border.color: Kirigami.Theme.negativeTextColor

        radius: 3

        implicitWidth: statsRow.implicitWidth + (border.width > 0 ? 8 : 0)
        implicitHeight: statsRow.implicitHeight + (border.width > 0 ? 4 : 0)

        Row {
            id: statsRow

            anchors.centerIn: parent
            spacing: 0

            Text {
                text: root.statsText()
                    + (Plasmoid.configuration.showBattery
                        && root.batterySensorBase.length > 0
                        && root.statsText().length > 0
                        ? " " + Plasmoid.configuration.separator + " "
                        : "")

                color: Kirigami.Theme.textColor
                font.pointSize: Plasmoid.configuration.fontSize
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                visible: Plasmoid.configuration.showBattery && root.batterySensorBase.length > 0
                text: root.batteryText()
                color: root.batteryColor()

                font.pointSize: Plasmoid.configuration.fontSize
                verticalAlignment: Text.AlignVCenter
            }
        }

        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
    }

    fullRepresentation: Text {
        text: "CPU: " + cpuSensor.formattedValue
            + "\nRAM: " + ramSensor.formattedValue
            + "\nCPU temperature: " + cpuTempSensor.formattedValue
            + "\nDownload: " + downloadSensor.formattedValue
            + "\nUpload: " + uploadSensor.formattedValue
    }
}