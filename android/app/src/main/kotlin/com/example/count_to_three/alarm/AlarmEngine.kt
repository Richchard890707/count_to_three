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
        volumeRamp: Boolean = false,
        vibrate: Boolean = true,
        ringtoneUri: String? = null,
    ) {
        val alarm = AlarmData(
            id = alarmId,
            reminderId = reminderId,
            title = title,
            scheduledAt = triggerAtMs,
            snoozeMinutes = snoozeMinutes,
            maxSnoozeCount = maxSnoozeCount,
            volumeRamp = volumeRamp,
            vibrate = vibrate,
            ringtoneUri = ringtoneUri,
        )
        AlarmStore.put(context, alarm)
        AlarmScheduler.schedule(context, alarm)
    }

    fun cancelAlarm(context: Context, alarmId: Int) {
        AlarmScheduler.cancel(context, alarmId)
        AlarmStore.remove(context, alarmId)
    }

    fun snoozeAlarm(context: Context, alarmId: Int) {
        val alarm = AlarmStore.get(alarmId) ?: return
        if (alarm.snoozeCount >= alarm.maxSnoozeCount) {
            cancelAlarm(context, alarmId)
            AlarmEventBus.emit(com.example.count_to_three.alarm.model.AlarmEvent.Dismissed(alarmId, alarm.reminderId, alarm.scheduledAt, auto = true))
            return
        }
        val snoozed = alarm.copy(
            snoozeCount = alarm.snoozeCount + 1,
            scheduledAt = System.currentTimeMillis() + alarm.snoozeMinutes * 60_000L,
        )
        AlarmStore.put(context, snoozed)
        AlarmScheduler.schedule(context, snoozed)
        AlarmEventBus.emit(com.example.count_to_three.alarm.model.AlarmEvent.Snoozed(alarmId, alarm.reminderId, alarm.scheduledAt, snoozed.snoozeCount))
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
