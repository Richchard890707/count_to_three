package com.example.count_to_three.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat

object NotificationHelper {
    private const val CHANNEL_ID = "alarm_firing"
    const val NOTIFICATION_ID = 1001

    fun createChannel(context: Context) {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "鬧鐘響鈴",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            setBypassDnd(true)
            setShowBadge(false)
            enableVibration(false)
            setSound(null, null)
        }
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(channel)
    }

    fun buildFiringNotification(context: Context, title: String, alarmId: Int): Notification {
        val fsiIntent = Intent(context, AlarmActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_USER_ACTION
            putExtra("alarm_id", alarmId)
        }
        val fsiPending = PendingIntent.getActivity(
            context, alarmId, fsiIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val stopPending = PendingIntent.getService(
            context,
            alarmId * 10 + 1,
            Intent(context, AlarmService::class.java).apply {
                action = AlarmService.ACTION_STOP
                putExtra("alarm_id", alarmId)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val snoozePending = PendingIntent.getService(
            context,
            alarmId * 10 + 2,
            Intent(context, AlarmService::class.java).apply {
                action = AlarmService.ACTION_SNOOZE
                putExtra("alarm_id", alarmId)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText("點擊查看")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSound(null)
            .setFullScreenIntent(fsiPending, true)
            .addAction(0, "停止", stopPending)
            .addAction(0, "貪睡", snoozePending)
            .build()
    }
}
