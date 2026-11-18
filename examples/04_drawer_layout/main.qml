import QtQuick
import QtQuick.Window
import QtQuick.Layouts 1.15
import Nova 1.0

Window {
    width: 1000
    height: 600
    visible: true
    title: "NovaDrawer Header Picture Test"
    color: "#121212"

    Rectangle {
        id: layoutRoot
        anchors.fill: parent
        anchors.margins: 16
        color: "#121212"
        radius: 8
        border.color: "#333333"
        border.width: 1
        clip: true

        NovaHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56
            z: 10
            color: "#00838F" 
            
            title: "Header"
            
            appendSlotContent: [
                NovaButton {
                    label: "☰"
                    variant: "text"
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: leftDrawer.toggle()
                }
            ]
        }

        NovaPage {
            id: pageContainer
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            padding: 16
            scrollable: true
            z: 1 

            Column {
                width: parent.width
                spacing: 16
                Repeater {
                    model: 15
                    Text {
                        text: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Fugit nihil praesentium molestias a adipisci, dolore vitae odit, quidem consequatur optio voluptates asperiores pariatur eos numquam rerum delectus commodi perferendis voluptate?"
                        color: "#e0e0e0"
                        font.pixelSize: 15
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            states: [
                State {
                    name: "drawerOpen"
                    when: layoutRoot.width >= 400
                    PropertyChanges { target: pageContainer; anchors.leftMargin: 200 }
                },
                State {
                    name: "drawerClosed"
                    when: layoutRoot.width < 400
                    PropertyChanges { target: pageContainer; anchors.leftMargin: 0 }
                }
            ]
            transitions: Transition {
                NumberAnimation { properties: "anchors.leftMargin"; duration: 250; easing.type: Easing.InOutQuad }
            }
        }

        NovaDrawer {
            id: leftDrawer
            side: "left"
            permanent: layoutRoot.width >= 400 
            breakpoint: 400
            expandedWidth: 200
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            z: 20 

            utilityClasses: "bg-background" 
            bordered: true 

            Item {
                id: profileHeader
                width: parent.width
                height: 150
                clip: true 

                Image {
                    anchors.fill: parent
                    source: "https://cdn.quasar.dev/img/material.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 80
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: "#000000" }
                    }
                    opacity: 0.8
                }

                NovaAvatar {
                    size: Units.px(56)
                    anchors.left: parent.left
                    anchors.leftMargin: Units.px(16)
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Units.px(36)
                    source: "https://cdn.quasar.dev/img/boy-avatar.png"
                    text: "R" 
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Units.px(16)
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Units.px(12)
                    spacing: Units.px(2)

                    Text {
                        text: "Razvan Stoenescu"
                        color: "white"
                        font.pixelSize: Units.px(15)
                        font.bold: true
                    }
                    Text {
                        text: "@rstoenescu"
                        color: "#b0b0b0"
                        font.pixelSize: Units.px(13)
                    }
                }
            }

            NovaList {
                anchors.top: profileHeader.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                NovaItem { icon: "📥"; label: "Inbox"; clickable: true; onClicked: console.log("Clicked Inbox") }
                NovaItem { icon: "⭐"; label: "Star"; clickable: true; active: true; onClicked: console.log("Clicked Star") }
                NovaItem { icon: "✈️"; label: "Send"; clickable: true; onClicked: console.log("Clicked Send") }
                NovaItem { icon: "📝"; label: "Drafts"; clickable: true; onClicked: console.log("Clicked Drafts") }
            }
        }
    }
}
