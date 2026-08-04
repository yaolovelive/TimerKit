# Inbox 查看 + 提醒（EventKit 转换 / 快速本地提醒）Implementation Plan

**状态：已完成并提交（2026-08-04）**

> 本文档补记两轮已经落地的工作，供后续查阅"当时为什么这么设计"。原始交互式计划文件在
> `/Users/alyjiya/.claude/plans/apps-watchos-quirky-toast.md`（Claude Code 会话级临时文件，
> 不在仓库里，第二轮开始时被同一路径覆盖），执行时用了 `codex:rescue` 子代理实施，
> 人工复核 + `swift test` + 两端 `xcodebuild` 通过后分两个仓库提交。

## Context

`docs/03-features.md` 的 Quick Capture 规格分三块：记录、查看（Inbox）、提醒。按
`docs/09-roadmap.md`，这些本该在 P1（macOS）/P2（iOS）阶段一起交付，但实际开发时只做了
"记录"——`CapturePanel`/`CaptureSheet` 能存 `Memo`，`CaptureDetector` 能识别日期/URL/待办等，
但没有查看入口，也没有提醒能力。当前仓库在推进 P3（watchOS）期间补齐了这两块被跳过的功能。

补完过程中发现用户实际想要两种不同语义的"提醒"，因此拆成了两轮：

1. **Inbox 查看 + 转系统提醒（EventKit）**：把文本里能解析出绝对日期的 memo 一次性推给系统
   「提醒事项」App。
2. **快速提醒（Check-in Reminder，本地通知）**：捕获时顺手选一个相对延时（30 分钟/2 小时/
   明天），到点用 App 自己的本地通知问"这件事现在还成立吗"，通知带"已完成"/"还没"快捷操作，
   不依赖文本里有可解析日期，也不需要打开系统提醒事项 App。两条路径并存、互不干扰。

## 第一轮：Inbox 查看 + 转系统提醒（EventKit）

**外层仓库提交**：`84ed6e7` P3 补完: Inbox 归档 + 提醒转换的 TimerKit 逻辑
**Apps 仓库提交**：`318da0c` P3 补完: macOS/iOS Inbox 查看视图 + 转系统提醒

### TimerKit（`Sources/TimerKit/`）

- [x] `Models/Memo.swift`：加 `archived: Bool = false`（additive-only，登记进
      `docs/10-schema-lock.md`）
- [x] `Capture/MemoStore.swift`：补完 `archiveStale`，新增 `archive(_:)` / `delete(_:)`
- [x] 新建 `Capture/InboxFilter.swift`：三个智能分组（Reminders/Links/Questions）+ 按
      `pomodoroID` 筛选的纯函数，`Tests/TimerKitTests/InboxFilterTests.swift` 覆盖
- [x] 新建 `Capture/ReminderConverter.swift`：从 `.date` detection 提取标题+到期时间
      （纯函数可测），`#if os(iOS) || os(macOS)` 包裹 EventKit 提交部分（`saveToSystemReminders`），
      watchOS 不编译（EventKit 在 watchOS 上不存在）

### App targets（`Apps/`）

- [x] `macOS/Views/InboxView.swift`、`iOS/Views/InboxView.swift`：`@Query` 读取
      `Memo`，`InboxFilter` 分组渲染 `List`，swipe 归档/删除/转提醒
- [x] `bottomToolbar` 加入口按钮（`IconButton(systemName: "tray")`）
- [x] `iOS/Info.plist` + macOS build setting 补 `NSRemindersUsageDescription`

### 范围外（明确不做）

- watchOS Inbox 界面（屏幕太小，规格里也没提）
- "attach to current pomodoro"swipe action（事后把 memo 挂到某个 pomodoro，语义模糊）
- 月度 AI 回顾、WCSession 同步 Inbox 状态（属 P4/v1.1）

## 第二轮：快速提醒（Check-in Reminder，本地通知）

**外层仓库提交**：`7a304dc` 新增快速提醒（Check-in Reminder）本地通知功能
**Apps 仓库提交**：`d36b5ac` 快速提醒: macOS/iOS 延时选择器 + 本地通知 action 接线

### TimerKit（`Sources/TimerKit/`，不加 `#if os()` 限制——`UserNotifications` 三端均可用）

- [x] `Models/Memo.swift`：新增 `CheckInReminder { scheduledFor, completedAt }` 结构体 +
      `Memo.checkInReminder` 字段（additive-only，登记进 `docs/10-schema-lock.md`）
- [x] 新建 `Capture/CheckInDelay.swift`：`thirtyMinutes` / `twoHours` / `tomorrow` 三档
      纯函数 `fireDate(from:calendar:)`，`Tests/TimerKitTests/CheckInDelayTests.swift` 覆盖
      （`tomorrow` 用 `Calendar.date(byAdding:)` 而非 `+24h`，避免夏令时误差）
- [x] 新建 `Capture/CheckInScheduler.swift`：`scheduledDate`/`applyMarkDone`/`applySnooze`
      纯函数可测（`Tests/TimerKitTests/CheckInSchedulerTests.swift`），`registerCategory`/
      `scheduleCheckIn`/`handleAction` 做 `UNNotificationCategory`/`UNNotificationRequest`
      副作用（identifier `"checkin-\(memo.id)"`，category `"MEMO_CHECKIN"`，action
      `MARK_DONE`/`SNOOZE`）
- [x] `Engine/FocusController.swift`：加 `selectedCheckInDelay`，`saveCapture` 存完 memo 后
      按选择调度
- [x] `UI/SharedComponents.swift`：新增 `CheckInDelayPicker`（chip 视觉参照
      `DetectionChip`）

### App targets（`Apps/`）

- [x] `macOS/CheckInNotificationDelegate.swift`、`iOS/CheckInNotificationDelegate.swift`：
      `UNUserNotificationCenterDelegate`，`didReceive response:` 里按 `userInfo["memoID"]`
      调 `CheckInScheduler.handleAction`
- [x] `TactApp.swift`/`iOSApp.swift` 的 `init()`：设 delegate + 调一次
      `CheckInScheduler.registerCategory()`
- [x] `CapturePanel`（macOS）/`CaptureSheet`（iOS）加 `CheckInDelayPicker`
- [x] `MacFocusController`/`IOSFocusController` 加 `selectedCheckInDelay` passthrough
- [x] `InboxView.swift`（两端）：`checkInReminder` 未完成时显示时钟图标（纯展示，无新
      swipe action）

### 范围外（明确不做）

- watchOS：捕获走系统听写面板，没有可点选 chip 的容器，逻辑本身平台无关但 UI 这次不接
- Inbox 里手动补设置/取消延时提醒的 swipe action——用户强调"捕获时顺手定"，事后管理需要
  再单开计划
- 和 EventKit 路径的整合/去重——两条路径并存

## 验证记录

- `swift test`：外层仓库全量通过（第一轮 37 项，第二轮追加后 42 项，均含新增测试套件）
- `xcodebuild build -scheme "Tact" -destination 'platform=macOS'`：`BUILD SUCCEEDED`
- `xcodebuild build -scheme "iOS" -destination 'id=<iPhone 17 Pro 模拟器>'`：`BUILD SUCCEEDED`
  （连带内嵌的 watchOS target 一并编译，确认两轮改动都没影响 watchOS 构建）
- 手动运行验证（通知交互、Inbox 分组/图标）未做——上面两次 `xcodebuild` 只验证了编译，
  真机/模拟器上的通知权限授予、`MARK_DONE`/`SNOOZE` 按钮实际点击效果仍需要后续手动跑一遍
