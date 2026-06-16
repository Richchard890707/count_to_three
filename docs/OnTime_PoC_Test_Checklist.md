# 準點鬧鐘 PoC — 完整測試 Checklist (S1–S10)

> 用途:Android 鬧鐘可靠度 PoC 的完整測試清單,可交給 Claude Cowork 協助追蹤進度、執行 adb 指令、整理結果。
> Package id: `com.example.ontime`

---

## 圖例

- **Status**:`✅ PASS` / `❌ FAIL` / `⏳ PENDING` / `⏭️ SKIP`(emulator 限制)/ `🔲 TODO`
- **Env**:`E` = emulator 可測 / `D` = 必須實機 / `D*` = 強烈建議實機 / `OEM` = 多廠牌實機

---

## S1 — Native Alarm Path

**目標**:button → `setAlarmClock` → Receiver → 通知 + 鈴聲

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S1-1 | E | 安裝後第一次啟動 | 主畫面顯示三個按鈕 | ✅ |
| S1-2 | E | POST_NOTIFICATIONS 權限請求 | Android 13+ 第一次啟動跳出系統權限對話框 | ✅ |
| S1-3 | E | 按 RE-CHECK PERMISSIONS | 狀態列顯示 `Notifications: OK ExactAlarm: OK` | ✅ |
| S1-4 | E | 按 SCHEDULE (+30s) | Logcat 出現 `PoC.Scheduler setAlarmClock id=1 at=...` | ✅ |
| S1-5 | E | 排程後狀態列右上角 | 出現鬧鐘 icon 🕐 | ✅ |
| S1-6 | E | App 前景時等 30 秒 | Logcat `PoC.Receiver FIRED id=1` | ✅ |
| S1-7 | E | App 背景(Home 鍵)時等 30 秒 | 同 S1-6 | ✅ |
| S1-8 | E | **App 滑掉後等 30 秒** | Logcat `FIRED` 仍出現(關鍵測試) | ✅ |
| S1-9 | E | 鎖屏狀態等 30 秒 | 鎖屏出現 `OnTime Alarm` 通知 | ✅ |
| S1-10 | E | 按 CANCEL | 狀態列鬧鐘 icon 消失,時間到不會響 | ✅ |
| S1-11 | E | 排兩次相同 id(覆蓋) | 第二次排程覆蓋第一次,只響一次 | 🔲 |

**S1 通過條件**:S1-8 + S1-9 通過

---

## S2 — Foreground Service + MediaPlayer

**目標**:鈴聲播放搬到 FGS,App 被殺也能持續播

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S2-1 | E | 排程後等 30 秒 | Logcat 四行序列出現:`FIRED` → `startForegroundService dispatched` → `Service onStartCommand` → `MediaPlayer prepared` | ✅ |
| S2-2 | E | 鬧鐘響時鎖屏點亮看通知 | 出現持續性通知,**無法滑除** | ✅ |
| S2-3 | E | 鬧鐘響時下拉通知欄 | 通知顯示為「鬧鐘」分類(category alarm)| 🔲 |
| S2-4 | D* | 鬧鐘響時聽鈴聲 | 預設鬧鐘鈴聲(走 USAGE_ALARM)| ⏭️ (emulator 音訊問題)|
| S2-5 | D* | 鬧鐘響時音量鍵調整 | 調整「鬧鐘音量」slider 會影響音量 | ⏳ |
| S2-6 | E | 5 分鐘不動它 | Logcat `Auto-stop after 300s timeout` + `onDestroy` | 🔲 |
| S2-7 | E | App 滑掉後 30 秒響鈴 | Service 啟動完整流程,通知出現 | ✅ |
| S2-8 | E | 強制停 Service | `adb shell am stopservice com.example.ontime/.AlarmService` 立即停止 | 🔲 |
| S2-9 | E | DND 模式(勿擾)| 通知仍可見(setBypassDnd 生效)| 🔲 |

**S2 通過條件**:S2-1 + S2-2 + S2-7 通過

---

## S3 — Full-Screen Alarm Activity

**目標**:鎖屏狀態下螢幕自動點亮 + 全螢幕鬧鐘 UI

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S3-1 | E | 排程後 App 滑掉、鎖屏、等 30 秒 | Logcat 多一行 `PoC.AlarmActivity onCreate` | ✅ |
| S3-2 | D* | 鎖屏螢幕自動點亮 | 30 秒後螢幕**自動亮起來**,不需手動 | ⏭️ (emulator turnScreenOn 不穩定)|
| S3-3 | E | 全螢幕鬧鐘 UI | 出現黑底 + OnTime Alarm 標題 + 即時時鐘 + DISMISS 按鈕 | ✅ |
| S3-4 | E | 鎖屏狀態下 UI 顯示 | 不需解鎖,UI 直接覆蓋鎖屏 | ✅ |
| S3-5 | E | 點 DISMISS 按鈕 | 鈴聲停 + Activity 關閉 + 回到鎖屏 | ✅ |
| S3-6 | E | 鬧鐘響時 Activity 是否在 recents | 切到 Recents 看不到鬧鐘 Activity(excludeFromRecents) | 🔲 |
| S3-7 | E | App 前景時觸發鬧鐘 | 出現 heads-up 通知(非全螢幕),點通知開啟 Activity | 🔲 |
| S3-8 | E | 鬧鐘響時按返回鍵 | Activity 關閉但 Service 繼續播(S4 會修正)| 🔲 |

**S3 通過條件**:S3-1 + S3-3 + S3-4 + S3-5 通過

---

## S4 — Stop / Snooze State Machine

**目標**:正式的 STOP / SNOOZE 兩按鈕 + 完整鬧鐘狀態機

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S4-1 | E | 鬧鐘響時顯示兩按鈕 | UI 上有 STOP(紅)+ SNOOZE(灰)| 🔲 |
| S4-2 | E | 按 STOP | 鈴聲停 + 通知消失 + Activity 關閉 + Service stopSelf | 🔲 |
| S4-3 | E | 按 SNOOZE(5 分鐘)| 鈴聲停 + 5 分鐘後重新觸發完整鬧鐘流程 | 🔲 |
| S4-4 | E | Snooze 後 Logcat | `setAlarmClock` 用相同 id、新觸發時間;`snoozeCount=1` | 🔲 |
| S4-5 | E | 連續 Snooze 達上限(3 次)| 第 4 次自動 STOP(AUTO_DISMISSED)| 🔲 |
| S4-6 | E | 5 分鐘無人理會 | AUTO_DISMISSED + Logcat 顯示原因 | 🔲 |
| S4-7 | E | Snooze 後從 MainActivity 取消 | 取消後 5 分鐘不會再響 | 🔲 |
| S4-8 | E | 鬧鐘響時按返回鍵 | Activity 不關閉(防誤觸)或回到鎖屏但 Service 仍持有 | 🔲 |
| S4-9 | E | 狀態機 log 完整 | 每次狀態轉換有 log:`SCHEDULED→FIRING→SNOOZED→FIRING→DISMISSED` | 🔲 |

**S4 通過條件**:S4-2 + S4-3 + S4-5 + S4-6 通過

---

## S5 — AlarmStore 持久化(JSON)

**目標**:鬧鐘資料持久化,App 重啟後仍知道

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S5-1 | E | 排程後 App 重啟 | 主畫面列表仍顯示該鬧鐘 | 🔲 |
| S5-2 | E | 排多個鬧鐘(id=1, 2, 3)| 全部都正確觸發 | 🔲 |
| S5-3 | E | Snooze 後 App 重啟 | snoozeCount 正確保留 | 🔲 |
| S5-4 | E | Cancel 後 App 重啟 | 該鬧鐘從列表消失 | 🔲 |
| S5-5 | E | JSON 檔案位置可確認 | `adb shell run-as com.example.ontime ls files/` 看到 alarms.json | 🔲 |
| S5-6 | E | 壞檔測試(手動破壞 JSON)| App 啟動不 crash,而是清空 + log 警告 | 🔲 |

**S5 通過條件**:S5-1 + S5-2 + S5-4 通過

---

## S6 — Boot Recovery

**目標**:裝置重開機後鬧鐘仍會響

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S6-1 | E | 排程後重啟 emulator | 重啟後 `adb shell dumpsys alarm \| grep ontime` 仍可看到鬧鐘 | 🔲 |
| S6-2 | E | 排程後重啟 + 等到觸發時間 | 鬧鐘準時響(完整流程)| 🔲 |
| S6-3 | E | 模擬 BOOT_COMPLETED broadcast | `adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -p com.example.ontime` 後 Logcat 有 BootReceiver log | 🔲 |
| S6-4 | E | 已過期鬧鐘 boot 後處理 | 標 MISSED,不再觸發,但 log/UI 提示 | 🔲 |
| S6-5 | E | App 升級後(MY_PACKAGE_REPLACED) | 鬧鐘自動重排 | 🔲 |
| S6-6 | E | 時區變更(`adb shell setprop persist.sys.timezone`)| 鬧鐘重排,相對時間保持 | 🔲 |
| S6-7 | D | 真實裝置重啟 | 鬧鐘照樣準時 | 🔲 |

**S6 通過條件**:S6-2 + S6-3 通過

---

## S7 — Flutter MethodChannel 整合

**目標**:從 Flutter 端能完整操作鬧鐘(取代 native MainActivity)

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S7-1 | E | Flutter 端呼叫 `alarm.schedule` | 原生端收到、setAlarmClock 成功 | 🔲 |
| S7-2 | E | Flutter 端呼叫 `alarm.cancel` | 原生端取消成功 | 🔲 |
| S7-3 | E | Flutter 端呼叫 `alarm.list` | 回傳所有排程中的鬧鐘 | 🔲 |
| S7-4 | E | Flutter 端呼叫 `alarm.permissions` | 回傳 4 個權限狀態的 map | 🔲 |
| S7-5 | E | 經由 Flutter 排程 → App 殺掉 → 鬧鐘響 | 完整 S1–S4 流程仍正確 | 🔲 |
| S7-6 | E | Method 錯誤情境 | 過期時間 → 回傳 `INVALID_TIME` 錯誤 | 🔲 |

**S7 通過條件**:S7-1 + S7-5 通過

---

## S8 — EventChannel 事件推送

**目標**:Native 事件能推送到 Flutter

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S8-1 | E | App 前景時鬧鐘響 | Flutter 收到 `onAlarmFired` | 🔲 |
| S8-2 | E | App 前景時按 SNOOZE | Flutter 收到 `onAlarmSnoozed` 含新 trigger time | 🔲 |
| S8-3 | E | App 前景時按 STOP | Flutter 收到 `onAlarmDismissed` | 🔲 |
| S8-4 | E | 重啟後掃漏響 | Flutter 收到 `onAlarmMissed` 列表 | 🔲 |
| S8-5 | E | App 背景時事件 | 重新進入 App 時補送 / 或不送但無 crash | 🔲 |

**S8 通過條件**:S8-1 + S8-2 + S8-3 通過

---

## S9 — OEM 引導 + 權限 UX

**目標**:第一次啟動引導 + OEM 偵測 + 設定頁深連結

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S9-1 | E | 第一次啟動 onboarding | 顯示 3 步權限引導頁(通知→精確鬧鐘→電池白名單)| 🔲 |
| S9-2 | E | 偵測 manufacturer | `Build.MANUFACTURER` 正確讀取 | 🔲 |
| S9-3 | OEM | 三星裝置引導 | 顯示三星專屬步驟 + 截圖 | 🔲 |
| S9-4 | OEM | 小米裝置引導 | 顯示自啟動 + 省電策略步驟 | 🔲 |
| S9-5 | OEM | OPPO/realme 裝置 | 顯示應用程式耗電量管理步驟 | 🔲 |
| S9-6 | OEM | vivo 裝置 | 顯示 iManager 引導 | 🔲 |
| S9-7 | E | 電池白名單一鍵跳轉 | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent 開啟系統頁 | 🔲 |
| S9-8 | E | 可靠度檢查頁 | 列出所有權限的紅綠燈狀態 | 🔲 |

**S9 通過條件**:S9-1 + S9-7 + S9-8 通過(OEM 在 S10 統一驗)

---

## S10 — 完整可靠度驗收

**目標**:跨情境、跨 OEM 全面驗證

### 10.1 可靠性(Reliability)

| # | Env | Test | Pass Criterion | Status |
|---|-----|------|----------------|--------|
| S10-R1 | E | Doze 模式 | `adb shell dumpsys deviceidle force-idle deep` 後鬧鐘仍響 | 🔲 |
| S10-R2 | E | App Standby Bucket | `adb shell am set-standby-bucket com.example.ontime rare` 後鬧鐘仍響 | 🔲 |
| S10-R3 | D* | 移除最近任務 + 等 30 分鐘 | 仍準時響(Pixel 必須通過)| 🔲 |
| S10-R4 | D | 螢幕關閉 2 小時以上 | 準時響 | 🔲 |
| S10-R5 | E | 連續排 20 個鬧鐘 | 全部正確觸發 | 🔲 |
| S10-R6 | E | 時間向後撥 1 小時 | 鬧鐘相對時間正確 | 🔲 |
| S10-R7 | D | 飛航模式 | 鬧鐘照響(本地不依賴網路)| 🔲 |
| S10-R8 | D | 低電量模式 | 鬧鐘照響 | 🔲 |

### 10.2 OEM 測試矩陣

| # | 裝置 | Doze 測試 | OEM 殺手測試 | 重開機測試 | Overall |
|---|------|-----------|--------------|------------|---------|
| S10-O1 | Pixel(Stock,基準)| 🔲 | 🔲 | 🔲 | 🔲 |
| S10-O2 | Samsung(One UI) | 🔲 | 🔲 | 🔲 | 🔲 |
| S10-O3 | 小米(HyperOS) | 🔲 | 🔲 | 🔲 | 🔲 |
| S10-O4 | OPPO / realme | 🔲 | 🔲 | 🔲 | 🔲 |
| S10-O5 | vivo | 🔲 | 🔲 | 🔲 | 🔲 |
| S10-O6 | 華為(可選)| 🔲 | 🔲 | 🔲 | 🔲 |

每台測試動作:
- 排程鬧鐘 → 移除最近任務 → 等 30 分鐘以上 → 確認響起
- 開機後等到原排程時間 → 確認響起
- 嘗試引導使用者加入電池白名單後重複測試

---

## 常用 adb 指令參考(交給 Cowork 執行)

```bash
# 即時 log,只看 PoC tag
adb logcat -c
adb logcat -v time PoC.Main:I PoC.Scheduler:I PoC.Receiver:I PoC.Service:I PoC.AlarmActivity:I *:S

# 確認鬧鐘已註冊到系統
adb shell dumpsys alarm | grep -A 5 com.example.ontime

# 通知 channel 確認
adb shell dumpsys notification | grep -A 10 com.example.ontime

# Service 狀態
adb shell dumpsys activity services com.example.ontime

# 強制 Doze 進深度
adb shell dumpsys deviceidle force-idle deep
# 退出 Doze
adb shell dumpsys deviceidle unforce

# 模擬開機完成(不需真重啟)
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -p com.example.ontime

# 強殺 App
adb shell am force-stop com.example.ontime

# 強停 Service
adb shell am stopservice com.example.ontime/.AlarmService

# 模擬 standby bucket
adb shell am set-standby-bucket com.example.ontime rare
# 查詢目前 bucket
adb shell am get-standby-bucket com.example.ontime

# 模擬螢幕電源
adb shell input keyevent KEYCODE_POWER

# 看 JSON 持久化檔(S5)
adb shell run-as com.example.ontime ls files/
adb shell run-as com.example.ontime cat files/alarms.json

# 重置電池統計
adb shell dumpsys batterystats --reset
# 一段時間後檢查
adb shell dumpsys batterystats --checkin > batterystats.txt
```

---

## 目前進度 Summary

| Stage | 名稱 | 狀態 | 備註 |
|-------|------|------|------|
| S1 | Native Alarm Path | ✅ PASS | 全數通過 |
| S2 | Foreground Service + MediaPlayer | ✅ PASS | 鈴聲輸出未驗(emulator 限制),邏輯路徑全通 |
| S3 | Full-Screen Alarm Activity | ✅ PASS | turnScreenOn 在 emulator 不穩定(S10 實機補驗)|
| S4 | Stop / Snooze State Machine | 🔲 TODO | 下一步 |
| S5 | AlarmStore 持久化 | 🔲 TODO | |
| S6 | Boot Recovery | 🔲 TODO | |
| S7 | Flutter MethodChannel | 🔲 TODO | |
| S8 | EventChannel 事件 | 🔲 TODO | |
| S9 | OEM 引導 + 權限 UX | 🔲 TODO | |
| S10 | 完整可靠度驗收 | 🔲 TODO | OEM 部分需多台實機 |

---

## 給 Cowork 的使用建議

1. **逐階段執行**:S1 → S2 → ... → S10,前一階段未通過不進入下一階段
2. **狀態維護**:每完成一項把 🔲 改成 ✅ / ❌ / ⏭️
3. **失敗時**:把 Logcat 完整貼出,標註是哪個 test ID
4. **emulator 跳過項**:標 `⏭️` 並註明等實機階段(S10)補驗
5. **OEM 測試**:列出已測機型 + Android 版本 + One UI/MIUI/ColorOS 等版本
