package com.example.count_to_three.alarm.model

sealed class AlarmEvent {
    data class Fired(val alarmId: Int, val reminderId: String, val title: String) : AlarmEvent()
    data class Snoozed(val alarmId: Int, val reminderId: String, val snoozeCount: Int) : AlarmEvent()
    data class Dismissed(val alarmId: Int, val reminderId: String, val auto: Boolean = false) : AlarmEvent()

    fun toMap(): Map<String, Any> = when (this) {
        is Fired -> mapOf(
            "type" to "fired",
            "alarmId" to alarmId,
            "reminderId" to reminderId,
            "title" to title,
        )
        is Snoozed -> mapOf(
            "type" to "snoozed",
            "alarmId" to alarmId,
            "reminderId" to reminderId,
            "snoozeCount" to snoozeCount,
        )
        is Dismissed -> mapOf(
            "type" to "dismissed",
            "alarmId" to alarmId,
            "reminderId" to reminderId,
            "auto" to auto,
        )
    }
}
