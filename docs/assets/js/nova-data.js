/* 生成物：scripts/gen_apidocs.py 产出，禁止手工编辑。
   事实源：__about__.py + api/nova-api-1.2.0.json + QML + 60 张三态图 */
window.NOVA_SITE = {
  "version": "1.2.1",
  "fingerprint": "4f882374ad52262b",
  "typesTotal": 144,
  "repo": "https://github.com/eagleye-china/pyside-nova",
  "pypi": "https://pypi.org/project/pyside-nova/",
  "versions": [
    {
      "label": "1.2.1 · 当前站点（GA）",
      "url": ""
    },
    {
      "label": "1.2.1 · PyPI 发布页",
      "url": "https://pypi.org/project/pyside-nova/1.2.1/"
    },
    {
      "label": "main · 开发分支",
      "url": "https://github.com/eagleye-china/pyside-nova"
    }
  ],
  "components": [
    {
      "name": "NovaDualSide",
      "category": "主导航",
      "title": "双侧边工作台",
      "description": "NovaDualSide 双侧边工作台壳：左导航 + 中央画布 + 右属性，两侧独立折叠（对标 Qt Designer / VSCode 三栏布局） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；两侧宽度归零 + 恒定锚链（CC-5）； primary/secondary 撞色标识收敛主色系角标（CC-3）；每边界唯一分隔源；槽位宿主独立铺满（CC-6）。 用法：向 leftSlot/contentSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "dual_side",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "leftCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "leftSize",
          "type": "real",
          "default": "240",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "rightCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "rightSize",
          "type": "real",
          "default": "280",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "contentSlot",
        "footerSlot",
        "leftSlot",
        "overlaySlot",
        "rightSlot"
      ],
      "signals": [
        "leftToggled",
        "rightToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaDualSide.qml"
    },
    {
      "name": "NovaSidebar",
      "category": "主导航",
      "title": "侧边导航工作台",
      "description": "NovaSidebar 侧边导航工作台壳：单色系品牌渐变轨 + 浮起侧栏卡 + 五槽骨架（对标 Quasar QLayout + QDrawer） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 visible 三元跳变）； 每边界唯一分隔源；primary→secondary 撞色渐变收敛为主色系、装饰改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 headerSlot/sidebarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "sidebar",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "1024",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root._bp",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "sidebarCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "sidebarSize",
          "type": "real",
          "default": "260",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "contentSlot",
        "footerSlot",
        "headerSlot",
        "overlaySlot",
        "sidebarSlot"
      ],
      "signals": [
        "sidebarToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaSidebar.qml"
    },
    {
      "name": "NovaTabShell",
      "category": "主导航",
      "title": "标签页工作台",
      "description": "NovaTabShell 标签页工作台壳：下划线激活指示条 + 标签栏 + 内容容器 + 状态栏（对标 Quasar QTabs） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 三色段落收敛主色系递减条、删底边重复分隔线（CC-2/CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 tabBarSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "tab_shell",
      "props": [
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showTabBar",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "tabBarHeight",
          "type": "int",
          "default": "44",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "contentSlot",
        "footerSlot",
        "overlaySlot",
        "tabBarSlot"
      ],
      "signals": [
        "tabActivated",
        "tabAddRequested",
        "tabCloseRequested"
      ],
      "file": "Nova/Composite/LayoutShell/NovaTabShell.qml"
    },
    {
      "name": "NovaTopNavigation",
      "category": "主导航",
      "title": "顶部导航工作台",
      "description": "NovaTopNavigation 顶部导航工作台壳：胶囊导航台 + 悬浮下拉 + 主内容 + 状态栏（对标 Quasar QLayout header 导航） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 单一分隔源、装饰收敛主色系抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 headerSlot/menuSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "top_navigation",
      "props": [
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "menuHeight",
          "type": "int",
          "default": "160",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "menuOpen",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "contentSlot",
        "footerSlot",
        "headerSlot",
        "menuSlot",
        "overlaySlot"
      ],
      "signals": [
        "menuToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaTopNavigation.qml"
    },
    {
      "name": "NovaCardGrid",
      "category": "多栏工作台",
      "title": "卡片网格壳",
      "description": "NovaCardGrid 卡片网格壳：筛选工具条 + 网格骨架 + 分页状态栏（对标组件画廊 / 模板市场） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 伪筛选胶囊 / 伪视图切换钮改为主色系抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 filterSlot/gridSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "card_grid",
      "props": [
        {
          "name": "filterHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "padding",
          "type": "int",
          "default": "12",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showFilter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "filterSlot",
        "footerSlot",
        "gridSlot",
        "overlaySlot"
      ],
      "signals": [],
      "file": "Nova/Composite/LayoutShell/NovaCardGrid.qml"
    },
    {
      "name": "NovaCompare",
      "category": "多栏工作台",
      "title": "双栏对比壳",
      "description": "NovaCompare 双栏对比壳：中缝分隔 + 等宽双面板 + 控制栏 + 状态栏（对标代码 / 配置 diff 工具） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； A/B 贯穿色条与伪调节柄箭头改为主色系角标 + 抽象短条（CC-2/CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 controlSlot/leftSlot/rightSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "compare",
      "props": [
        {
          "name": "controlHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "divider",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showControl",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "syncScroll",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "controlSlot",
        "footerSlot",
        "leftSlot",
        "overlaySlot",
        "rightSlot"
      ],
      "signals": [
        "syncScrollToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaCompare.qml"
    },
    {
      "name": "NovaThreeColumn",
      "category": "多栏工作台",
      "title": "三栏工作台",
      "description": "NovaThreeColumn 三栏工作台壳：目录树 / 中列表 / 详情，三级深度色阶（对标资源管理器布局） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 深色顶条与 primary→secondary 渐变收敛主色系、伪 grip 改抽象短条（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 treeSlot/listSlot/detailSlot/headerSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "three_column",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "detailSize",
          "type": "real",
          "default": "320",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "treeSize",
          "type": "real",
          "default": "220",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "detailSlot",
        "footerSlot",
        "headerSlot",
        "listSlot",
        "overlaySlot",
        "treeSlot"
      ],
      "signals": [
        "columnResized"
      ],
      "file": "Nova/Composite/LayoutShell/NovaThreeColumn.qml"
    },
    {
      "name": "NovaDrawerPanel",
      "category": "浮层容器",
      "title": "侧边滑出面板壳",
      "description": "NovaDrawerPanel 侧边滑出面板壳：单色系侧缘轨 + 抽象短条 + 非模态临时面板（区别于常驻 Sidebar） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； primary→secondary 撞色轨收敛主色系、伪 grabber 把手改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）。 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "drawer_panel",
      "props": [
        {
          "name": "actionsHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "open",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "bySide",
          "type": "string",
          "default": "NovaTheme.isRtl ? (root.side === \"left\" ? \"right\" : \"left\") : root.side",
          "readonly": true,
          "kind": "string"
        },
        {
          "name": "scrim",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showActions",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showTitle",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "side",
          "type": "string",
          "default": "\"right\"",
          "readonly": false,
          "kind": "string"
        },
        {
          "name": "size",
          "type": "real",
          "default": "360",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "titleHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "actionsSlot",
        "contentSlot",
        "titleSlot"
      ],
      "signals": [
        "closeRequested"
      ],
      "file": "Nova/Composite/LayoutShell/NovaDrawerPanel.qml"
    },
    {
      "name": "NovaModal",
      "category": "浮层容器",
      "title": "模态弹窗壳",
      "description": "NovaModal 模态弹窗壳：单色系顶条 + 抽象短条 + 浮起卡片 + 遮罩，ESC / 点遮罩关闭（对标 Quasar QDialog） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 三色渐变顶条收敛主色系、伪拖拽把手改抽象几何（CC-3）；槽位宿主独立铺满（CC-6）；遮罩为功能性例外。 用法：向 titleSlot/contentSlot/actionsSlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "modal",
      "props": [
        {
          "name": "actionsHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "dismissOnMask",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "maxHeight",
          "type": "real",
          "default": "620",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "maxWidth",
          "type": "real",
          "default": "520",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "open",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showActions",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showTitle",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "titleHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "actionsSlot",
        "contentSlot",
        "titleSlot"
      ],
      "signals": [
        "closeRequested"
      ],
      "file": "Nova/Composite/LayoutShell/NovaModal.qml"
    },
    {
      "name": "NovaBlankPage",
      "category": "独立页壳",
      "title": "纯净单页壳",
      "description": "NovaBlankPage 纯净单页壳：居中阅读栏 + Header + Content + Footer，最克制的可定制基底（无侧栏 / 无标签导航） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 阅读栏 padding 与 NovaPage padding 合并为单一边距（CC-1）；槽位宿主独立铺满（CC-6）。 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "blank_page",
      "props": [
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "padding",
          "type": "int",
          "default": "24",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "contentSlot",
        "footerSlot",
        "headerSlot",
        "overlaySlot"
      ],
      "signals": [],
      "file": "Nova/Composite/LayoutShell/NovaBlankPage.qml"
    },
    {
      "name": "NovaSetupWizard",
      "category": "独立页壳",
      "title": "安装配置向导壳",
      "description": "NovaSetupWizard 安装配置向导壳：三态步骤时间轴 + 当前步内容 + 上一步/下一步控制区（对标 Quasar QStepper） 组合态（宪法 1.0.0 CARF-R）：_ 私有组合上下文统一密度/层级/动效；栏高归零 + 恒定锚链（CC-5）； 两个仿交互控件改抽象几何（CC-3）；业务步骤指示器提级到装饰之上（友好度）；槽位宿主独立铺满（CC-6）。 用法：向 stepsSlot/contentSlot/controlsSlot/footerSlot/overlaySlot 注入业务内容；注入顶层须 anchors.fill: parent",
      "prefix": "setup_wizard",
      "props": [
        {
          "name": "controlsHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "currentStep",
          "type": "int",
          "default": "0",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "canGoNext",
          "type": "bool",
          "default": "root.currentStep < root.stepCount - 1",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "canGoPrevious",
          "type": "bool",
          "default": "root.currentStep > 0",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showSteps",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "stepCount",
          "type": "int",
          "default": "3",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "stepsHeight",
          "type": "int",
          "default": "64",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "contentSlot",
        "controlsSlot",
        "footerSlot",
        "overlaySlot",
        "stepsSlot"
      ],
      "signals": [
        "nextRequested",
        "previousRequested",
        "stepSelected"
      ],
      "file": "Nova/Composite/LayoutShell/NovaSetupWizard.qml"
    },
    {
      "name": "NovaDesktop",
      "category": "多端根壳",
      "title": "桌面应用根壳",
      "description": "NovaDesktop 桌面应用根壳：窗口控制点 + 菜单栏 + 工具栏 + 页面 + 状态栏（对标 QMainWindow），组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一三栏密度/层级/动效；栏高归零 + 恒定锚链（CC-5，消除 visible 三元跳变）； 每边界唯一分隔源；三色控制点收敛主色系、仿交互控件方块改抽象几何（CC-3）；槽位宿主铺满（CC-6）。 用法：向 menuSlot/toolbarSlot/pageSlot/statusSlot/overlaySlot 注入业务内容；根节点为应用窗口内容根，不含 ApplicationWindow",
      "prefix": "desktop",
      "props": [
        {
          "name": "menuHeight",
          "type": "int",
          "default": "32",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showMenu",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showStatus",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showToolbar",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "statusHeight",
          "type": "int",
          "default": "28",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "toolbarHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "menuSlot",
        "overlaySlot",
        "pageSlot",
        "statusSlot",
        "toolbarSlot"
      ],
      "signals": [
        "windowCloseRequested"
      ],
      "file": "Nova/Composite/LayoutShell/NovaDesktop.qml"
    },
    {
      "name": "NovaFlexLayout",
      "category": "多端根壳",
      "title": "企业大屏弹性布局壳",
      "description": "NovaFlexLayout 企业大屏弹性布局壳：columns 驱动的浮起面板网格 + 自适应分栏（HMI / 工控大屏），组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一网格密度/层级/动效；header/footer 高度归零 + 恒定锚链（CC-5）； 三色渐变底线与三色面板顶条收敛主色系（CC-3）；每边界唯一分隔源；槽位宿主铺满（CC-6）。 用法：向 headerSlot/contentSlot/footerSlot/overlaySlot 注入业务内容；columns 与断点驱动分栏，缩放取 NovaScreen",
      "prefix": "flex",
      "props": [
        {
          "name": "columns",
          "type": "int",
          "default": "3",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "footerHeight",
          "type": "int",
          "default": "48",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "gap",
          "type": "int",
          "default": "8",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "64",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "scalable",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showFooter",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "contentSlot",
        "footerSlot",
        "headerSlot",
        "overlaySlot"
      ],
      "signals": [
        "layoutChanged"
      ],
      "file": "Nova/Composite/LayoutShell/NovaFlexLayout.qml"
    },
    {
      "name": "NovaMobile",
      "category": "多端根壳",
      "title": "移动应用根壳",
      "description": "NovaMobile 移动应用根壳：安全区 + 灵动岛 + 内容 + 底部导航 + home indicator（对标 Quasar QLayout mobile），组合态一致性契约（CC）落地 组合态（宪法 0.9.0）：_ 私有组合上下文统一安全区/头/底栏密度与动效；栏高归零 + 恒定锚链（CC-5）； 每边界唯一分隔源；灵动岛与 home indicator 收敛主色系抽象几何（CC-3）；槽位宿主铺满（CC-6）。 用法：向 headerSlot/contentSlot/bottomNavSlot/overlaySlot 注入业务内容；安全区由 safeTop/safeBottom 属性注入",
      "prefix": "mobile",
      "props": [
        {
          "name": "bottomNavHeight",
          "type": "int",
          "default": "60",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "56",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "isTouch",
          "type": "bool",
          "default": "NovaPlatform.isMobile",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "safeBottom",
          "type": "int",
          "default": "0",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "safeTop",
          "type": "int",
          "default": "0",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showBottomNav",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "bottomNavSlot",
        "contentSlot",
        "headerSlot",
        "overlaySlot"
      ],
      "signals": [
        "backRequested"
      ],
      "file": "Nova/Composite/LayoutShell/NovaMobile.qml"
    },
    {
      "name": "NovaChat",
      "category": "AI 对话主窗口",
      "title": "六轨按轨分治主窗口",
      "description": "NovaChat AI 对话主窗口壳：六槽多轨工作台（对标 WorkBuddy 桌面端主窗口），组合态一致性契约（CC）落地标杆 组合态（宪法 0.9.0）：根内以 _ 私有 readonly 声明唯一组合上下文（密度/层级/动效/品牌色），六轨共享； 相邻边界只有一条分隔源；身份装饰一律抽象几何、禁止仿交互控件、同屏品牌色收敛为主色系； 折叠锚链恒定不依赖 visible 三元切换。全部为 _ 私有 PATCH，公共 API 签名逐字不变、冻结指纹不变。",
      "prefix": "chat",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "960",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "composerHeight",
          "type": "int",
          "default": "132",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "conversationCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "conversationSize",
          "type": "real",
          "default": "300",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "detailCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "detailSize",
          "type": "real",
          "default": "320",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "navCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "navSize",
          "type": "real",
          "default": "64",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root.breakpoint",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showComposer",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showConversation",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showDetail",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showHeader",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showNav",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "composerSlot",
        "contentSlot",
        "conversationSlot",
        "detailSlot",
        "headerSlot",
        "navSlot",
        "overlaySlot"
      ],
      "signals": [
        "conversationToggled",
        "detailToggled",
        "navToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaChat.qml"
    },
    {
      "name": "NovaAgent",
      "category": "AI 智能组合根",
      "title": "智能体任务执行工作台",
      "description": "NovaAgent 智能体任务执行工作台壳：任务列 + 编排画布 + 验证轨 + 审批闸（对标 NovaAgent 八项准入控制） 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享； 相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（DAG 节点环 / 风险分级色阶 / 闸门色带）， 不仿交互控件、不同屏撞色；折叠锚链恒定不依赖 visible 三元切换。",
      "prefix": "agent",
      "props": [
        {
          "name": "approvalHeight",
          "type": "int",
          "default": "96",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "960",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "headerHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root.breakpoint",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showApproval",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showPlan",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showTask",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showVerify",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "taskCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "taskSize",
          "type": "real",
          "default": "280",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "verifyCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "verifySize",
          "type": "real",
          "default": "300",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "approvalSlot",
        "contentSlot",
        "overlaySlot",
        "planSlot",
        "taskSlot",
        "verifySlot"
      ],
      "signals": [
        "approvalRequested",
        "taskToggled",
        "verifyToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaAgent.qml"
    },
    {
      "name": "NovaCopilot",
      "category": "AI 智能组合根",
      "title": "增强型协作面板",
      "description": "NovaCopilot 增强型协作面板壳：建议列 + 工作画布 + 动作闸门轨 （对标 NovaCopilot 建议—确认—执行契约与 Draft/Confirm/Read-Only 三模） 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享； 相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（内联胶囊条 / 闸门分隔点 /",
      "prefix": "copilot",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "1024",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "gateCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "gateSize",
          "type": "real",
          "default": "300",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "inlineHeight",
          "type": "int",
          "default": "44",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root.breakpoint",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showGate",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showInline",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showSuggest",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "suggestCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "suggestSize",
          "type": "real",
          "default": "280",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "contentSlot",
        "gateSlot",
        "inlineSlot",
        "overlaySlot",
        "suggestSlot"
      ],
      "signals": [
        "actionProposed",
        "gateToggled",
        "suggestToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaCopilot.qml"
    },
    {
      "name": "NovaDE",
      "category": "AI 智能组合根",
      "title": "数字员工岗位工作台",
      "description": "NovaDE 数字员工岗位工作台壳：岗位条 + 任务队列 + 工作画布 + SLA 轨 + 人工交接条 （对标 NovaDE 四要件：岗位形态 / 任务队列 / 能力调用 / 队伍级治理） 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全部轨共享； 相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（岗位菱形徽记 / 队列堆叠角标 /",
      "prefix": "de",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "1024",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "handoffHeight",
          "type": "int",
          "default": "84",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "queueCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "queueSize",
          "type": "real",
          "default": "300",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root.breakpoint",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "roleHeight",
          "type": "int",
          "default": "64",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "showHandoff",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showQueue",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showRole",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showSla",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "slaCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "slaSize",
          "type": "real",
          "default": "280",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "contentSlot",
        "handoffSlot",
        "overlaySlot",
        "queueSlot",
        "roleSlot",
        "slaSlot"
      ],
      "signals": [
        "handoffRequested",
        "queueToggled",
        "slaToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaDE.qml"
    },
    {
      "name": "NovaOrbit",
      "category": "意图轨道呈现层",
      "title": "意图轨道工作台",
      "description": "NovaOrbit 意图轨道工作台壳：全局栏 + 轨道态势栏 + 意图场 + 活产物画布（NovaChat 天花板形态） 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全轨共享； 相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（轨道发丝线 / 递减轨道链 / 并行分叉角标 / 双向箭头环 / 拓扑点阵），不仿交互控件、不同屏撞色；折叠锚链恒定。",
      "prefix": "orbit",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "1100",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "canvasCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "canvasSize",
          "type": "real",
          "default": "320",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "composerHeight",
          "type": "int",
          "default": "72",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "globalHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "mapHeight",
          "type": "int",
          "default": "120",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "railCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "railSize",
          "type": "real",
          "default": "260",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root.breakpoint",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showCanvas",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showComposer",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showGlobal",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showMap",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showRail",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        }
      ],
      "slots": [
        "canvasSlot",
        "composerSlot",
        "globalSlot",
        "intentSlot",
        "mapSlot",
        "overlaySlot",
        "railSlot"
      ],
      "signals": [
        "canvasToggled",
        "orbitRequested",
        "railToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaOrbit.qml"
    },
    {
      "name": "NovaIncubator",
      "category": "应用孵化器工作台",
      "title": "应用孵化器工作台",
      "description": "NovaIncubator 应用孵化器工作台壳：全局栏 + 配方库 + 孵化舞台 + CARF 四阶段条 + 三重校验 + 封版证书 + 浮层 组合态（宪法第 9 章 CC-1~CC-8）：根内 _ 私有 readonly 声明唯一组合上下文，全槽共享； 相邻边界只有一条 NovaSeparator；身份装饰一律抽象几何（递进楔形 / 五列配方栅 / 七区分格环 / 四节点收敛链 / 三道校验刻线 / 方章折角），不仿交互控件、不同屏撞色；折叠锚链恒定。",
      "prefix": "incubator",
      "props": [
        {
          "name": "bordered",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "breakpoint",
          "type": "int",
          "default": "1100",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "certificateHeight",
          "type": "int",
          "default": "160",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "globalHeight",
          "type": "int",
          "default": "52",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "pipelineHeight",
          "type": "int",
          "default": "64",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "recipeCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "recipeSize",
          "type": "real",
          "default": "260",
          "readonly": false,
          "kind": "number"
        },
        {
          "name": "belowBreakpoint",
          "type": "bool",
          "default": "width > 0 && width < root.breakpoint",
          "readonly": true,
          "kind": "bool"
        },
        {
          "name": "showCertificate",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showGlobal",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showPipeline",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showRecipe",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "showValidate",
          "type": "bool",
          "default": "true",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "validateCollapsed",
          "type": "bool",
          "default": "false",
          "readonly": false,
          "kind": "bool"
        },
        {
          "name": "validateSize",
          "type": "real",
          "default": "340",
          "readonly": false,
          "kind": "number"
        }
      ],
      "slots": [
        "certificateSlot",
        "globalSlot",
        "overlaySlot",
        "pipelineSlot",
        "recipeSlot",
        "stageSlot",
        "validateSlot"
      ],
      "signals": [
        "freezeRequested",
        "recipeToggled",
        "validateToggled"
      ],
      "file": "Nova/Composite/LayoutShell/NovaIncubator.qml"
    }
  ],
  "gallery": [
    "page-00.png",
    "page-01.png",
    "page-02.png",
    "page-03.png",
    "page-04.png",
    "page-05.png",
    "page-06.png",
    "page-07.png",
    "page-08.png",
    "page-09.png",
    "page-10.png",
    "page-11.png",
    "page-12.png",
    "page-13.png",
    "page-14.png",
    "page-15.png",
    "page-16.png",
    "page-17.png",
    "page-18.png",
    "page-19.png",
    "page-20.png",
    "page-21.png",
    "page-22.png",
    "page-23.png"
  ]
};
