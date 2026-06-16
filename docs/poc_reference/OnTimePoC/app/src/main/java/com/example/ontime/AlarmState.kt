package com.example.ontime

/**
 * S4 alarm lifecycle state.
 *
 *   IDLE → SCHEDULED → FIRING ─┬─→ DISMISSED       (user tapped STOP)
 *                              ├─→ AUTO_DISMISSED  (5-min timeout or snooze cap)
 *                              └─→ SNOOZED → FIRING (loop)
 *
 * S4 holds state in-memory only (AlarmStateStore).
 * S5 will persist this so reboot + process death don't lose snooze count.
 */
enum class AlarmState {
    IDLE,
    SCHEDULED,
    FIRING,
    SNOOZED,
    DISMISSED,
    AUTO_DISMISSED;

    val isTerminal: Boolean
        get() = this == DISMISSED || this == AUTO_DISMISSED
}