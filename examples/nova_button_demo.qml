import QtQuick 2.15
import Nova 1.0

Item {
    width: 600
    height: 400

    NovaButton {
        x: 100
        y: 100
        label: "Primary Filled"
        color: "#2196F3"
        variant: "filled"
        shape: "rounded"
        onClicked: console.log("click")
    }
}
