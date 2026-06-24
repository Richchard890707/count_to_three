package com.example.count_to_three.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.example.count_to_three.R

object NotificationHelper {
    // HIGH importance channel — used only as fallback fullScreenIntent trigger
    // when startActivity() cannot pierce the lock screen (older devices).
    private const val CHANNEL_HIGH = "alarm_firing"
    // LOW importance channel — used for the actual ongoing foreground notification
    // (no heads-up popup, just sits in the notification shade).
    private const val CHANNEL_LOW  = "alarm_ringing_silent"
    const val NOTIFICATION_ID = 1001

    fun createChannel(context: Context) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_HIGH, "鬧鐘觸發", NotificationManager.IMPORTANCE_HIGH).apply {
                setBypassDnd(true); setShowBadge(false)
                enableVibration(false); setSound(null, null)
            }
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_LOW, "鬧鐘進行中", NotificationManager.IMPORTANCE_LOW).apply {
                setBypassDnd(true); setShowBadge(false)
                enableVibration(false); setSound(null, null)
            }
        )
    }

    /** Silent ongoing notification shown while alarm is ringing — no heads-up, no action buttons. */
    fun buildFiringNotification(context: Context, title: String, alarmId: Int): Notification =
        NotificationCompat.Builder(context, CHANNEL_LOW)
            .setSmallIcon(R.drawable.ic_alarm_notif)
            .setContentTitle(title)
            .setContentText("鬧鐘響鈴中…")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSound(null)
            .build()

    /**
     * High-priority notification used as a fallback fullScreenIntent trigger for locked screens
     * on devices where startActivity() from a service is blocked.
     * Posted briefly then replaced by [buildFiringNotification].
     */
    fun buildFullScreenTrigger(context: Context, title: String, alarmId: Int): Notification {
        val activityIntent = Intent(context, AlarmActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("alarm_id", alarmId)
        }
        val activityPending = PendingIntent.getActivity(
            context, alarmId, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(context, CHANNEL_HIGH)
            .setSmallIcon(R.drawable.ic_alarm_notif)
            .setContentTitle(title)
            .setContentText("點擊查看鬧鐘")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSound(null)
            .setContentIntent(activityPending)  // tap → open AlarmActivity when screen is on
            .setFullScreenIntent(activityPending, true)
            .build()
    }
}
