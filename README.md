# 极简番茄钟 / PomodoroTimer

**[中文](#中文)** | **[English](#english)**

---

<a id="中文"></a>

## 中文

一款极简 macOS 菜单栏番茄钟计时器。无需登录、无需联网、无数据采集 —— 所有数据保存在本地。

### 功能特性

- **极简设计**：菜单栏常驻，点击即用
- **悬浮小窗口**：无边框半透明计时器，始终置顶，不遮挡工作
- **一键操作**：开始、暂停、重置，三个按钮搞定一切
- **鼠标悬停控制**：关闭和置顶按钮仅在鼠标移入时显示
- **位置记忆**：小窗口位置自动保存，下次打开恢复
- **右键菜单**：右击菜单栏图标可快速退出
- **专注时长可调**：默认 25 分钟，支持 1-120 分钟自定义

### 系统要求

- macOS 14 (Sonoma) 或更高版本
- Swift 5.9+ (Xcode 15+ Command Line Tools)

### 构建与运行

```bash
swift build
swift run PomodoroTimer
```

启动后菜单栏（右上角）会出现计时器图标。左键点击打开主面板，点击小窗口图标可打开悬浮计时器。

### 项目结构

```
Sources/PomodoroTimer/
  App/        入口、状态管理、状态栏控制器
  Models/     PomodoroPhase, TimerSettings
  Services/   TimerEngine, SettingsStore
  Views/      MenuBarContentView, StandaloneWindowView, SettingsView
```

### 许可证

个人使用。

---

<a id="english"></a>

## English

A minimalist macOS menu bar Pomodoro timer. No login, no network, no telemetry — all data stays local.

### Features

- **Minimalist design**: Lives in the menu bar, click to use
- **Floating widget**: Borderless, semi-transparent, always-on-top timer that doesn't block your work
- **One-tap controls**: Start, pause, reset — three buttons do it all
- **Hover to reveal**: Close and pin buttons appear only on mouse hover
- **Position memory**: Widget position is saved and restored on next launch
- **Right-click menu**: Right-click the menu bar icon to quickly quit
- **Adjustable focus duration**: Default 25 min, configurable from 1–120 min

### Requirements

- macOS 14 (Sonoma) or later
- Swift 5.9+ (Xcode 15+ Command Line Tools)

### Build & Run

```bash
swift build
swift run PomodoroTimer
```

A timer icon appears in the menu bar (top right). Left-click to open the popover, click the window icon to open the floating timer.

### Project Structure

```
Sources/PomodoroTimer/
  App/        Entry point, state management, status bar controller
  Models/     PomodoroPhase, TimerSettings
  Services/   TimerEngine, SettingsStore
  Views/      MenuBarContentView, StandaloneWindowView, SettingsView
```

### License

Personal use.
