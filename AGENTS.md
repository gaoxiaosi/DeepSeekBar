# DeepSeekBar
macOS 菜单栏应用，用于查询和展示 DeepSeek API 账户费用数据。

## 核心约束
- 纯菜单栏应用，使用 SwiftUI 的 `MenuBarExtra`，不在 Dock 显示
- 所有交互均在菜单栏下拉面板中完成，不打开任何独立窗口

## 数据获取
通过 DeepSeek 官方 API 获取并展示：
- 账户余额：总余额、今日消费金额、可用状态（GET /user/balance）

## API Key 管理
- 首次启动在菜单栏中弹出配置界面
- 菜单栏中提供“修改 API Key”入口

## 技术栈
SwiftUI + MenuBarExtra