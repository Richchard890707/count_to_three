package com.example.count_to_three.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.example.count_to_three.MainActivity
import com.example.count_to_three.alarm.model.AlarmData

object AlarmScheduler {

    fun schedule(context: Context, alarm: AlarmData) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val showIntent = PendingIntent.getActivity(
            context,
            alarm.id,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        try {
            am.setAlarmClock(
                AlarmManager.AlarmClockInfo(alarm.scheduledAt, showIntent),
                buildReceiverPendingIntent(context, alarm.id),
            )
        } catch (_: SecurityException) {
            // Exact alarm permission not granted — fall back to inexact
            am.set(
                AlarmManager.RTC_WAKEUP,
                alarm.scheduledAt,
                buildReceiverPendingIntent(context, alarm.id),
            )
        }
    }

    fun cancel(context: Context, alarmId: Int) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(buildReceiverPendingIntent(context, alarmId))
    }

    private fun buildReceiverPendingIntent(context: Context, alarmId: Int): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).putExtra("alarm_id", alarmId)
        return PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
