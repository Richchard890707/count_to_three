package com.example.count_to_three.alarm

import android.content.Context
import com.example.count_to_three.alarm.model.AlarmData

object AlarmEngine {

    fun init(context: Context) = AlarmStore.init(context)

    fun scheduleAlarm(
        context: Context,
        alarmId: Int,
        reminderId: String,
        title: String,
        triggerAtMs: Long,
        snoozeMinutes: Int = 5,
        maxSnoozeCount: Int = 3,
    ) {
        val alarm = AlarmData(
            id = alarmId,
            reminderId = reminderId,
            title = title,
            scheduledAt = triggerAtMs,
            snoozeMinutes = snoozeMinutes,
            maxSnoozeCount = maxSnoozeCount,
        )
        AlarmStore.put(context, alarm)
        AlarmScheduler.schedule(context, alarm)
    }

    fun cancelAlarm(context: Context, alarmId: Int) {
        AlarmScheduler.cancel(context, alarmId)
        AlarmStore.remove(context, alarmId)
    }

    fun getPendingAlarms(): List<Map<String, Any>> =
        AlarmStore.getAll().map {
            mapOf(
                "alarmId" to it.id,
                "reminderId" to it.reminderId,
                "title" to it.title,
                "triggerAtMs" to it.scheduledAt,
                "snoozeCount" to it.snoozeCount,
            )
        }
}
