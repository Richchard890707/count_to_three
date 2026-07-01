# 多情境計時器 — 夜間建置成果 (2026-07-01)

## 做了什麼

### 1. 健身漂亮版 UI(精緻化,照 UIUX 規格)
- resting:環繞大數字的**進度弧**(滿格對齊脊椎 135s,軟目標 tick)
- **三階段背景漸變**(藍灰→深青→深橘,AnimatedContainer 1200ms)
- 跨軟/脊椎閾值的**一次性脈動**(CustomPaint inset glow, 550ms)
- 頂部**「已健身 MM:SS」總時長 pill**(中性深玻璃,不染 accent,跨三底色恆定可讀)
- working:96sp X/N + 組點進度
- summary:總時長 + 總休息 + **做組:休息比例條**(推導「實際做組 = 總時長 − 總休息」)+ 每組水平長條(軟目標虛線 + 青/灰/橘語意色)
- 精緻大按鈕(按壓位移+縮放、光暈、ghost 樣式)
- 檔案:`presentation/screens/workout_timer_screen.dart`、`presentation/widgets/timer_theme.dart`

### 2. 煮飯(並行倒數)
- 多個獨立倒數 lane,各有標籤,從加入時各自倒數,到點各自叮(RestCue.spine)
- 隨時 +/− 一個倒數(FAB 新增對話框:標籤 + 分/秒)
- 檔案:`cooking/cooking_controller.dart`、`cooking/cooking_screen.dart`

### 3. 久坐(循環)
- 坐 X 分 → 叮起身 → 站 Y 分 → 叮坐下 → 循環;可設循環次數(4/8/無限)
- 站立階段背景轉青(動起來)
- 檔案:`sitting/sitting_controller.dart`、`sitting/sitting_screen.dart`

### 4. 情境選擇器
- 健身 / 煮飯 / 久坐 三張卡,`/timer` 路由改指這裡
- 檔案:`presentation/screens/scenario_picker_screen.dart`

## 驗證狀態
- ✅ `flutter build apk --debug` 通過(全部三情境 + 選擇器)
- ✅ 持久層單元測試通過(健身快照)
- ✅ 啟動不崩(pid alive、無 E/flutter/FATAL)
- ⚠️ 新情境的**畫面互動未肉眼驗證**:模擬器顯示器被測試操到卡死(渲染全黑),需在實體小米上實測

## 刻意的取捨(未做,理由)

1. **通用節奏引擎 + 健身遷移(架構 agent 的完整設計)未做**
   - 改為:煮飯/久坐做成**各自獨立的情境單元,共用配色(TimerTheme)+ 叮聲(audioCuePlayer)**。
   - 理由:通宵無人看管,把已驗證的健身邏輯重構到未證實的通用引擎風險太高。安全優先。
   - 現況耦合:cooking/sitting `import ... show audioCuePlayerProvider`(健身控制器檔),共用叮聲播放器。日後抽共用 provider 檔可解耦。

2. **煮飯/久坐無 DB 持久化(純記憶體)**
   - 理由:避開通用 Sessions 表 + schema 遷移(6→7)的風險;且這兩種較短暫、不太回顧歷史。
   - 健身仍有完整 DB 持久化 + 殺掉續跑。

3. **使用者自訂模式編輯器 UI 未做**(架構建議緩做,等三預設驗證需求)。

## 下一步(未來)
- 抽通用引擎、把三情境(含健身)統一到 Phase/Composition(架構 agent 設計已備)
- 煮飯/久坐加 DB 持久化(通用 Sessions/SessionRecords 表)
- 煮飯背景倒數的息屏通知(目前只有前景叮)
- 抽 `audioCuePlayerProvider` 到共用檔,解除 cooking/sitting → workout 的 import 耦合
