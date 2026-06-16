package com.example.count_to_three.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> rescheduleAll(context)
        }
    }

    private fun rescheduleAll(context: Context) {
        AlarmStore.init(context)
        val now = System.currentTimeMillis()
        AlarmStore.getAll().forEach { alarm ->
            if (alarm.scheduledAt <= now) {
                // Past-due: remove; Flutter will reschedule on next open
                AlarmStore.remove(context, alarm.id)
            } else {
                AlarmScheduler.schedule(context, alarm)
            }
        }
    }
}
