# ADR-001: scenario_timer 整合架構

**Status:** Proposed
**Date:** 2026-06-30
**Deciders:** richardc

## Context
新增前景健身組間計時器(醜版,目標=驗證 Model C)。要接上既有專案:
- Riverpod(codegen `@riverpod`)+ Drift(SQLite,schemaVersion=5)
- alarm_engine 已有乾淨的 `NotificationScheduler` 介面與 `LocalNotificationImpl`
- 不能破壞既有 calendar/reminder/alarm 功能

已有 system-design 報告(wall-clock 單調時鐘、雙軌叮震、Notifier 狀態機、Drift 快照 schema)。
本 ADR 把它**落地到真實介面**,並納入耳機研究結論(私密叮聲=可做、耳機手勢輸入=放棄)。

## Decision

### 1. 計時:單調時鐘,秒數為衍生值
- 進 `resting` 時 `Stopwatch()..start()`;顯示讀 `stopwatch.elapsed`。
- **狀態裡存 `restStartedAt`/stopwatch 基準,不存「當前秒數」**。背景→resume 不需補算。
- 不用 `DateTime.now()` 算差(避免健身房對時/NTP 漂移);DB 才另存牆鐘 epoch ms。

### 2. Ticker:新增秒級 provider(現有只有 minuteTick)
- `core/providers/tick_provider.dart` 只有 `minuteTickProvider`(60s)→ **不夠用**。
- 新增 feature 內 `restTickerProvider`(`autoDispose` StreamProvider,~1s)。只在 resting 畫面被 watch 時才跑,省電。

### 3. 狀態機:`@riverpod` Notifier(對齊既有 controller 慣例)
```
WorkoutTimerController extends _$WorkoutTimerController
  build() → WorkoutTimerState (sealed union: Setup/Working/Resting/Summary)
  方法: startSession(config) / finishSet() / readyForNext() / endSession()
```
- `Resting` 狀態持有 `restStartedAt` + `firedCues:Set<int>`;UI 衍生秒數 = watch `restTickerProvider` 現算。
- cue 觸發在 tick 回呼比對 `elapsed≥90/135 && !fired` → 軌道 A 叮 + 標記。

### 4. 叮震雙軌
- **軌道 A(前景,主力)**:私密耳機叮聲蓋過音樂(ducking)。**新依賴**:`audio_session`(設 duckOthers)+ `just_audio` 播叮聲。**叮完主動 deactivate** 還原音量(iOS 坑)。
- **軌道 B(息屏兜底)**:重用既有 `NotificationScheduler`:
  ```dart
  final sched = ref.read(notificationSchedulerProvider);
  sched.scheduleNotification(NotificationRequest(
    id: cueNotifId, reminderId: sessionId,   // 合成 id
    title: '休息到了', triggerAt: restStart.add(Duration(seconds: 90)),
  ));
  // resume 或進下一組 → sched.cancelNotification(cueNotifId)
  ```
- resume 時取消 B,用 `firedCues` 去重(同 cue 只認一次,A/B 誰先到都算)。

### 5. 持久化:新 Drift 表,快照 cue 設定(多情境相容)
- 新表 `WorkoutSessions` + `SetRecords`,加進 `@DriftDatabase`,**schemaVersion 5→6 + migration**(`onUpgrade` 建新表,不動舊表)。
- `SetRecords` 存 `restDurationMs`(已測真實毫秒,非兩 DateTime 相減)+ `cueConfigJson`(當下 90/135 快照)。
- 新 `WorkoutDao`。**UR 要求**:另存每次按鈕 tap 的 timestamp(dogfood 客觀數據)。

### 6. 重用邊界
| 既有組件 | 用不用 | 說明 |
|---|---|---|
| `NotificationScheduler`/`LocalNotificationImpl` | ✅ 借(軌道 B) | 唯一該共用的;透過 `notificationSchedulerProvider` |
| `appDatabaseProvider` / Drift 慣例 | ✅ 沿用 | 加表加 DAO |
| `@riverpod` Notifier 慣例 | ✅ 沿用 | 對齊 alarm_list_controller |
| `reschedule_window` | ❌ 不碰 | 背景精確鬧鐘配額機制,對前景計時器過度工程 |
| `rrule_engine` | ❌ 不碰 | 組間休息無 RRULE 語義 |
| `minuteTickProvider` | ❌ 不用 | 太粗,改用新 restTicker |

## 放棄(耳機研究結論)
- **耳機手勢輸入「進下一組」= 放棄**。iOS 無合法路;Android 僅 AccessibilityService 髒路且很可能收不到/順帶暫停音樂。連 spike 都省。
- 免手機**輸入**改為待驗證項(頭 3 次健身後再決定;候選:藍牙快門環)。醜版輸入先用「手機輕觸」。

## Consequences
- ✅ 變簡單:計時/叮震/狀態全靠既有積木 + 2 個小新依賴;舊功能零影響。
- ⚠️ 變難:Drift migration(5→6)要小心測;新增音訊 ducking 是專案首次,iOS deactivate 時機要顧。
- 🔁 要回頭看:免手機輸入(藍牙環/語音)等 dogfood 驗證後再定。

## Action Items
1. [ ] 加依賴:`audio_session`、`just_audio`
2. [ ] `domain/`:WorkoutTimerState union(已有 timer_phase/rest_record/workout_session 雛形,擴成 union)
3. [ ] `data/`:`RestCueScheduler`(包 NotificationScheduler 排/取消 +90/135)、`AudioCuePlayer`(ducking 叮聲)、`WorkoutDao` + 2 表 + migration 5→6
4. [ ] `presentation/`:`restTickerProvider`、`WorkoutTimerController`(Notifier)
5. [ ] UI 等 UIUX 定稿;先做能跑的醜版畫面驗證邏輯
6. [ ] dogfood log:按鈕 tap timestamp 落 DB
