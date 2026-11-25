// examples/carousel_demo/main.qml
// NovaCarousel 轮播演示：受控翻页 / 箭头 / 圆点导航 / 自动播放 / 无限回绕 /
// 拖拽手势 / 缩略图 / 垂直布局 / 自定义覆盖控件 / 禁用页 / 键盘可达。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nova.Services
import Nova.Controls

ApplicationWindow {
    id: win
    width: 860
    height: 720
    visible: true
    title: "NovaCarousel · 轮播组件演示"
    color: NovaTheme.page

    Component.onCompleted: {
        NovaScreen.source = win
        if (typeof novaIconLocalRoot !== "undefined" && novaIconLocalRoot !== "")
            NovaTheme.iconLocalRoot = novaIconLocalRoot
    }

    // 演示状态（受控模型）
    QtObject {
        id: state
        property var page: "spring"      // 当前页 name（受控 modelValue）
        property int visits: 0           // 翻页计数
        property string lastEvent: "—"   // 最近一次 transition 事件
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NovaTheme.spacingL
        spacing: NovaTheme.spacingM

        // ── 标题 ────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: "NovaCarousel · 轮播演示"
                font.family: NovaTheme.fontFamily
                font.pixelSize: NovaTheme.fontXL
                font.bold: true
                color: NovaTheme.textColor
            }
            Text {
                text: "对标 Quasar QCarousel · 子项即页 · 受控 modelValue 寻址"
                font.pixelSize: NovaTheme.fontS
                color: NovaTheme.textMuted
            }
        }

        // ── 受控状态条 ──────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: NovaTheme.radiusM
            color: NovaTheme.surface
            border.width: 1
            border.color: NovaTheme.outline

            RowLayout {
                anchors.fill: parent
                anchors.margins: NovaTheme.spacingS
                spacing: NovaTheme.spacingM
                Text {
                    text: "当前页：" + state.page + "   第 " + (carousel.currentIndex + 1) + " / " + carousel.count + " 页"
                    font.pixelSize: NovaTheme.fontM
                    color: NovaTheme.textColor
                    Layout.fillWidth: true
                }
                Text {
                    text: "翻页 " + state.visits + " 次 · 最近：" + state.lastEvent
                    font.pixelSize: NovaTheme.fontS
                    color: NovaTheme.textMuted
                }
                NovaBtn { text: "上一页"; onClicked: carousel.previous() }
                NovaBtn { text: "下一页"; onClicked: carousel.next() }
                NovaBtn { text: "跳到 summer"; onClicked: carousel.goTo("summer", true) }
            }
        }

        // ── 主轮播：全家桶 ──────────────────────────────────
        NovaCarousel {
            id: carousel
            Layout.fillWidth: true
            Layout.preferredHeight: 320

            modelValue: state.page
            arrows: true
            navigation: true
            navigationPosition: "bottom"
            thumbnails: false
            infinite: true
            swipeable: true
            animated: true
            autoplay: 4000
            transitionDuration: 300
            controlTint: NovaTheme.primary
            a11yLabel: "季度业绩轮播"

            NovaCarouselSlide {
                name: "spring"
                Rectangle {
                    anchors.fill: parent
                    color: "#1D9E75"
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "春季 · Spring"; font.pixelSize: 34; font.bold: true; color: "#fff" }
                        Text { text: "营收 1,280 万 · 同比 +18%"; font.pixelSize: 16; color: "#E1F5EE" }
                    }
                }
            }
            NovaCarouselSlide {
                name: "summer"
                Rectangle {
                    anchors.fill: parent
                    color: "#378ADD"
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "夏季 · Summer"; font.pixelSize: 34; font.bold: true; color: "#fff" }
                        Text { text: "营收 1,560 万 · 同比 +24%"; font.pixelSize: 16; color: "#E6F1FB" }
                    }
                }
            }
            NovaCarouselSlide {
                name: "autumn"
                disable: true   // 禁用页：next/goTo 自动跳过
                Rectangle {
                    anchors.fill: parent
                    color: "#BA7517"
                    Text { anchors.centerIn: parent; text: "秋季（禁用页，导航自动跳过）"; font.pixelSize: 20; color: "#fff" }
                }
            }
            NovaCarouselSlide {
                name: "winter"
                Rectangle {
                    anchors.fill: parent
                    color: "#534AB7"
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "冬季 · Winter"; font.pixelSize: 34; font.bold: true; color: "#fff" }
                        Text { text: "营收 1,890 万 · 同比 +31%"; font.pixelSize: 16; color: "#EEEDFE" }
                    }
                }
            }

            NovaCarouselControl {
                position: "bottom-right"
                offset: 12
                Rectangle {
                    width: 150; height: 30; radius: 15
                    color: Qt.rgba(0, 0, 0, 0.55)
                    Text {
                        anchors.centerIn: parent
                        text: "自定义覆盖控件 · " + state.visits + " 次"
                        color: "#fff"; font.pixelSize: NovaTheme.fontXS
                    }
                }
            }

            onUpdateModelValue: function(name) {
                state.page = name
                state.visits++
            }
            onTransition: function(info) {
                state.lastEvent = info.direction + " → " + info.newIndex
            }
        }

        Text {
            Layout.fillWidth: true
            text: "交互：← → 方向键 / Home / End · 鼠标拖拽翻页 · 点击箭头或圆点 · 自动播放（悬停不停）"
            font.pixelSize: NovaTheme.fontS
            color: NovaTheme.textMuted
            wrapMode: Text.Wrap
        }

        // ── 垂直轮播：缩略图导航 ────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            spacing: NovaTheme.spacingM

            ColumnLayout {
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                spacing: 4
                Text {
                    text: "垂直轮播 + 缩略图导航"
                    font.pixelSize: NovaTheme.fontM
                    font.bold: true
                    color: NovaTheme.textColor
                }
                NovaCarousel {
                    id: vcarousel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    vertical: true
                    arrows: true
                    navigation: true
                    navigationPosition: "right"
                    infinite: false
                    swipeable: true
                    autoplay: false

                    NovaCarouselSlide {
                        name: "red"
                        Rectangle { anchors.fill: parent; color: "#A32D2D" }
                    }
                    NovaCarouselSlide {
                        name: "green"
                        Rectangle { anchors.fill: parent; color: "#3B6D11" }
                    }
                    NovaCarouselSlide {
                        name: "blue"
                        Rectangle { anchors.fill: parent; color: "#0C447C" }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "垂直模式：方向键自动切为 ↑ ↓；箭头移到上下边；导航点停靠右侧。开启 thumbnails: true 并为页设置 imgSrc 即可显示缩略图导航。"
                font.pixelSize: NovaTheme.fontS
                color: NovaTheme.textMuted
                wrapMode: Text.Wrap
            }
        }
    }
}
