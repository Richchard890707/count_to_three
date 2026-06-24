package com.example.count_to_three.alarm.model

sealed class AlarmEvent {
    data class Fired(
        val alarmId: Int,
        val reminderId: String,
        val title: String,
        val scheduledAtMs: Long,
        val snoozeCount: Int = 0,
        val maxSnoozeCount: Int = 3,
    ) : AlarmEvent()
    data class Snoozed(
        val alarmId: Int,
        val reminderId: String,
        val scheduledAtMs: Long,
        val snoozeCount: Int,
    ) : AlarmEvent()
    data class Dismissed(
        val alarmId: Int,
        val reminderId: String,
        val scheduledAtMs: Long,
        val auto: Boolean = false,
    ) : AlarmEvent()

    fun toMap(): Map<String, Any> = when (this) {
        is Fired -> mapOf(
            "type" to "fired",
            "alarmId" to alarmId,
            "reminderId" to reminderId,
            "title" to title,
            "scheduledAtMs" to scheduledAtMs,
            "snoozeCount" to snoozeCount,
            "maxSnoozeCount" to maxSnoozeCount,
        )
        is Snoozed -> mapOf(
            "type" to "snoozed",
            "alarmId" to alarmId,
            "reminderId" to reminderId,
            "scheduledAtMs" to scheduledAtMs,
            "snoozeCount" to snoozeCount,
        )
        is Dismissed -> mapOf(
            "type" to "dismissed",
            "alarmId" to alarmId,
            "reminderId" to reminderId,
            "scheduledAtMs" to scheduledAtMs,
            "auto" to auto,
        )
    }
}
