# NovaButton v1.0 Final 组件规范文档
> 项目：pyside-nova（QML版企业级组件库）
> 对标：Quasar QBtn
> 契约对齐：pyside-quasar Widget版 Button
> 状态：✅ 封版 Final，仅Bug修复，不做破坏性接口变更
> 无依赖：不引入 QtQuick.Controls，自研绘制，适配HMI、工业触摸屏

## 1. 基础信息
| 项目 | 值 |
| ---- | ---- |
| 组件名称 | NovaButton |
| 版本 | v1.0.0 Final |
| QML导入 | `import Nova 1.0` |
| 底层基类 | Item（内部封装 FocusScope） |
| QML依赖模块 | QtQuick 2.15、QtQuick.Layouts 1.15、QtQuick.Shapes 1.15 |
| 存放路径 | `src/pyside_nova/qml/Nova/NovaButton.qml` |
| 配套模块声明 | `src/pyside_nova/qml/Nova/qmldir` |

### qmldir 文件内容
