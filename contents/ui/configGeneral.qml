import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root

    property alias cfg_showCpu: showCpu.checked
    property alias cfg_showRam: showRam.checked
    property alias cfg_showTemperature: showTemperature.checked
    property alias cfg_showDownload: showDownload.checked
    property alias cfg_showUpload: showUpload.checked
    property alias cfg_updateInterval: updateInterval.value
    property alias cfg_separator: separator.text
    property alias cfg_fontSize: fontSize.value
    property alias cfg_showBattery: showBattery.checked
    property alias cfg_batteryWarning: batteryWarning.value
    property alias cfg_batteryCritical: batteryCritical.value
    property alias cfg_batteryCriticalBorder: batteryCriticalBorder.checked

    QQC2.CheckBox {
        id: showCpu
        Kirigami.FormData.label: "Visible metrics:"
        text: "CPU usage"
    }

    QQC2.CheckBox {
        id: showRam
        text: "Memory usage"
    }

    QQC2.CheckBox {
        id: showTemperature
        text: "CPU temperature"
    }

    QQC2.CheckBox {
        id: showDownload
        text: "Download speed"
    }

    QQC2.CheckBox {
        id: showUpload
        text: "Upload speed"
    }

    QQC2.SpinBox {
        id: updateInterval

        Kirigami.FormData.label: "Update interval:"
        from: 250
        to: 10000
        stepSize: 250

        textFromValue: function(value) {
            if (value < 1000) {
                return value + " ms"
            }

            return (value / 1000) + " s"
        }

        valueFromText: function(text) {
            const value = parseFloat(text)

            if (text.toLowerCase().includes("ms")) {
                return value
            }

            return value * 1000
        }
    }

    QQC2.TextField {
        id: separator

        Kirigami.FormData.label: "Separator:"
        placeholderText: "│"
        maximumLength: 10
    }

    QQC2.SpinBox {
        id: fontSize

        Kirigami.FormData.label: "Font size:"
        from: 6
        to: 24
        stepSize: 1

        textFromValue: function(value) {
            return value + " pt"
        }

        valueFromText: function(text) {
            return parseInt(text)
        }
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    Kirigami.Heading {
        text: "Battery"
        level: 4
    }

    QQC2.CheckBox {
        text: "Show battery"
        checked: cfg_showBattery

        onToggled: {
            cfg_showBattery = checked
        }
    }

    RowLayout {
        QQC2.Label {
            text: "Warning level:"
        }

        QQC2.SpinBox {
            from: 1
            to: 100
            value: cfg_batteryWarning

            onValueModified: {
                cfg_batteryWarning = value
            }
        }

        QQC2.Label {
            text: "%"
        }
    }

    RowLayout {
        QQC2.Label {
            text: "Critical level:"
        }

        QQC2.SpinBox {
            from: 1
            to: 100
            value: cfg_batteryCritical

            onValueModified: {
                cfg_batteryCritical = value
            }
        }

        QQC2.Label {
            text: "%"
        }
    }

    QQC2.CheckBox {
        text: "Show red border at critical level"
        checked: cfg_batteryCriticalBorder

        onToggled: {
            cfg_batteryCriticalBorder = checked
        }
    }

    QQC2.CheckBox {
        id: showBattery

        Kirigami.FormData.label: "Battery:"
        text: "Show battery"
    }

    QQC2.SpinBox {
        id: batteryWarning

        Kirigami.FormData.label: "Warning level:"
        from: 1
        to: 100
        stepSize: 1

        textFromValue: function(value) {
            return value + " %"
        }

        valueFromText: function(text) {
            return parseInt(text)
        }
    }

    QQC2.SpinBox {
        id: batteryCritical

        Kirigami.FormData.label: "Critical level:"
        from: 1
        to: 100
        stepSize: 1

        textFromValue: function(value) {
            return value + " %"
        }

        valueFromText: function(text) {
            return parseInt(text)
        }
    }

    QQC2.CheckBox {
        id: batteryCriticalBorder

        Kirigami.FormData.label: "Critical warning:"
        text: "Show red border"
    }
}