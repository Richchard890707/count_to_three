package com.example.ontime

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

/**
 * S3 notification helper. Adds fullScreenIntent so the alarm UI launches automatically
 * when the screen is off or locked.
 *
 * fullScreenIntent behaviour:
 *   - Screen off / locked → AlarmActivity launches directly, screen wakes.
 *   - Screen on, user in another app → heads-up notification; tapping launches AlarmActivity.
 *
 * Requires:
 *   - Channel importance HIGH or above (already satisfied since S2).
 *   - USE_FULL_SCREEN_INTENT permission (added to manifest in S3).
 */
object NotificationHelper {

    const val CHANNEL_ID = "alarm_firing"
    private const val CHANNEL_NAME = "Alarm ringing"
    private const val CHANNEL_DESC = "Foreground notification while an alarm is ringing"

    const val FGS_NOTIF_ID = 1001

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        if (nm.getNotificationChannel(CHANNEL_ID) != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = CHANNEL_DESC
            setSound(null, null)              // MediaPlayer owns sound
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 600, 400, 600, 400)
            setBypassDnd(true)
            lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            setShowBadge(true)
        }
        nm.createNotificationChannel(channel)
    }

    fun buildForegroundAlarmNotification(
        context: Context,
        alarmId: Int,
        title: String = "OnTime Alarm"   // S5: now accepts custom title
    ): Notification {
        val fullScreenIntent = Intent(context, AlarmActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_NO_USER_ACTION
            )
            putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
        }
        val fsiPending = PendingIntent.getActivity(
            context, alarmId, fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText("Alarm is ringing (id=$alarmId)")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(fsiPending)
            .setFullScreenIntent(fsiPending, true)
            .build()
    }
}