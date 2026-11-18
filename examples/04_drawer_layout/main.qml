import QtQuick
import QtQuick.Window
import QtQuick.Layouts 1.15
import Nova 1.0

Window {
    width: 1000
    height: 600
    visible: true
    title: "NovaDrawer Overlay Mode Test"
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

        // ==========================================
        // 1. 顶部 Header
        // ==========================================
        NovaHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56
            z: 10
            color: "#00838F" 
            title: "Header"
            
            prependSlotContent: [
                NovaButton {
                    variant: "text"
                    icon: "menu"
                    textColor: "white"
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        leftDrawer.toggle()
                    }
                }
            ]
        }

        // ==========================================
        // 2. 主内容区
        // ==========================================
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
        }

        // ==========================================
        // 3. 遮罩层 (Scrim)
        // ==========================================
        Rectangle {
            id: scrim
            anchors.fill: parent
            anchors.topMargin: header.height
            color: "#000000"
            opacity: leftDrawer.opened ? 0.4 : 0
            visible: opacity > 0
            z: 15
            
            Behavior on opacity { NumberAnimation { duration: 250 } }

            MouseArea {
                anchors.fill: parent
                onClicked: leftDrawer.hide()
            }
        }

        // ==========================================
        // 4. 抽屉 (Overlay 悬浮模式)
        // ==========================================
        NovaDrawer {
            id: leftDrawer
            side: "left"
            overlay: true      
            permanent: false   
            opened: false      
            expandedWidth: 200
            breakpoint: 500
            
            // 🌟 核心修复：删掉 anchors.left，让底层自己控制 x 坐标实现滑动动画
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            z: 20

            utilityClasses: "bg-grey-9" 
            bordered: true 

            // 阻止点击穿透到遮罩层
            MouseArea {
                anchors.fill: parent
                z: -1
            }

            NovaList {
                anchors.fill: parent
                anchors.topMargin: Units.px(8)
                z: 1

                NovaItem { icon: "inbox"; label: "Inbox"; clickable: true }
                NovaItem { icon: "star"; label: "Star"; clickable: true; active: true }
                NovaItem { icon: "send"; label: "Send"; clickable: true }
                NovaItem { icon: "drafts"; label: "Drafts"; clickable: true }
                NovaItem { icon: "delete"; label: "Spam"; clickable: true }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                NovaItem { icon: "settings"; label: "Settings"; clickable: true }
            }
        }
    }
}
