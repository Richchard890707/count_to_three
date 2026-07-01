import 'package:flutter/material.dart';

import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart';

/// 情境計時器設計 token(UIUX 規格)。語意對應、刻意不用紅。
class TimerTheme {
  TimerTheme._();

  // 背景場色
  static const calm = Color(0xFF1B2430); // 安靜底
  static const cyanField = Color(0xFF0E3D3A); // resting 建議開始整片場
  static const amberField = Color(0xFF5A3A12); // resting 脊椎整片場

  // accent
  static const cyan = Color(0xFF00D2C8);
  static const onCyan = Color(0xFF06302E);
  static const amber = Color(0xFFE0892B);
  static const onAmber = Color(0xFF3A2206);
  static const neutral = Color(0xFF7C8B99);

  // 文字 / 表面
  static const textPrimary = Color(0xFFE8EDF0);
  static const glass = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const hairline = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)

  // 中性 pill(總時長)
  static const pillGlass = Color(0x8C0C121A); // rgba(12,18,26,0.55)
  static const pillStroke = Color(0x24FFFFFF); // rgba(255,255,255,0.14)
  static const onPill = Color(0xEBE8EDF0); // rgba(232,237,240,0.92)

  /// resting 依已觸發的 cue 選整片背景場色。
  static Color fieldFor(Set<RestCue> firedCues) {
    if (firedCues.contains(RestCue.spine)) return amberField;
    if (firedCues.contains(RestCue.soft)) return cyanField;
    return calm;
  }
}
