package com.example.ontime

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log

object AlarmScheduler {
    private const val TAG = "PoC.Scheduler"
    const val ACTION_ALARM_FIRED = "com.example.ontime.ACTION_ALARM_FIRED"
    const val EXTRA_ALARM_ID = "alarm_id"

    fun schedule(context: Context, alarmId: Int, triggerAtMillis: Long, title: String) {
        setAlarmClockInternal(context, alarmId, triggerAtMillis)

        // Preserve snoozeCount and createdAt if re-scheduling an existing alarm
        val existing = AlarmStore.getById(context, alarmId)
        val alarm = AlarmData(
            id = alarmId,
            title = title,
            triggerAtMillis = triggerAtMillis,
            snoozeCount = existing?.snoozeCount ?: 0,
            createdAt = existing?.createdAt ?: System.currentTimeMillis()
        )
        AlarmStore.save(context, alarm)

        Log.i(TAG, "schedule id=$alarmId title='$title' at=$triggerAtMillis (in ${(triggerAtMillis - System.currentTimeMillis()) / 1000}s)")
    }

    fun snooze(context: Context, alarmId: Int, snoozeMillis: Long) {
        val current = AlarmStore.getById(context, alarmId)
        if (current == null) {
            Log.w(TAG, "snooze: id=$alarmId not in store")
            return
        }
        val newTriggerAt = System.currentTimeMillis() + snoozeMillis
        val updated = current.copy(
            triggerAtMillis = newTriggerAt,
            snoozeCount = current.snoozeCount + 1
        )
        AlarmStore.save(context, updated)
        setAlarmClockInternal(context, alarmId, newTriggerAt)
        Log.i(TAG, "snooze id=$alarmId for ${snoozeMillis / 1000}s count=${updated.snoozeCount}")
    }

    fun cancel(context: Context, alarmId: Int) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = buildFirePendingIntent(context, alarmId)
        am.cancel(pi)
        pi.cancel()
        AlarmStore.delete(context, alarmId)
        Log.i(TAG, "cancel id=$alarmId")
    }

    private fun setAlarmClockInternal(context: Context, alarmId: Int, triggerAtMillis: Long) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val operation = buildFirePendingIntent(context, alarmId)
        val showIntent = PendingIntent.getActivity(
            context, alarmId,
            Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAtMillis, showIntent), operation)
    }

    private fun buildFirePendingIntent(context: Context, alarmId: Int): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = ACTION_ALARM_FIRED
            putExtra(EXTRA_ALARM_ID, alarmId)
        }
        return PendingIntent.getBroadcast(
            context, alarmId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}