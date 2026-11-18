import QtQuick
import QtQuick.Window
import Nova 1.0

/**
 * @created 2026-11-18 15:00:00
 * @author  eagleye-china & 小诺 (AI Architect)
 * @module  Nova 1.0
 */
Window {
    width: 1200
    height: 600
    visible: true
    title: "NovaDrawer 旗舰版测试"
    color: Theme.background

    NovaDrawer {
        id: leftDrawer
        side: "left"
        permanent: true
        expandedWidth: Units.px(240)
        miniWidth: Units.px(60)
        mini: false
        bordered: true
        height: parent.height 
        
        Column {
            anchors.fill: parent
            anchors.topMargin: Units.px(16)
            anchors.leftMargin: Units.px(16)
            spacing: Units.px(16)
            Text { text: "🏠 首页"; font.pixelSize: Units.px(16); color: Theme.text_primary }
            Text { text: "📊 仪表盘"; font.pixelSize: Units.px(16); color: Theme.text_primary }
        }

        miniSlotContent: [
            Column {
                anchors.fill: parent
                anchors.topMargin: Units.px(16)
                spacing: Units.px(16)
                Text { text: "🏠"; font.pixelSize: Units.px(20) }
                Text { text: "📊"; font.pixelSize: Units.px(20) }
            }
        ]
    }

    // 背景遮罩层
    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        visible: overlayDrawer.opened
        z: 90
        MouseArea { anchors.fill: parent; onClicked: overlayDrawer.hide() }
    }

    // 悬浮 Drawer
    NovaDrawer {
        id: overlayDrawer
        side: "left"
        permanent: false
        overlay: true
        expandedWidth: Units.px(280)
        z: 100
        height: parent.height
        
        Rectangle {
            anchors.fill: parent
            color: Theme.primary
            Column {
                anchors.centerIn: parent
                spacing: Units.px(16)
                Text { text: "我是悬浮 Drawer"; color: "white"; font.pixelSize: Units.px(20); font.bold: true }
                NovaButton { 
                    label: "点击关闭"
                    width: Units.px(120)
                    height: Units.px(40)
                    onClicked: overlayDrawer.hide() 
                }
            }
        }
    }

    Item {
        id: mainContent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: leftDrawer.right
        
        Text {
            id: titleText
            text: "NovaDrawer 旗舰级测试台"
            font.pixelSize: Units.px(32)
            font.bold: true
            color: Theme.text_primary
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -60
        }

        NovaButton {
            label: leftDrawer.mini ? "展开左侧抽屉" : "收缩到 Mini 模式"
            width: Units.px(180)
            height: Units.px(44)
            anchors.top: titleText.bottom
            anchors.topMargin: Units.px(32)
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: leftDrawer.mini = !leftDrawer.mini
        }

        NovaButton {
            label: "打开悬浮抽屉"
            width: Units.px(180)
            height: Units.px(44)
            anchors.top: titleText.bottom
            anchors.topMargin: Units.px(96)
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                console.log("👉 悬浮按钮被点击，准备打开抽屉！")
                overlayDrawer.show()
                console.log("👉 抽屉状态:", overlayDrawer.opened)
            }
        }
    }
}
