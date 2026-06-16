package com.example.ontime

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * S6 boot recovery + state-change handler.
 *
 * Why this exists:
 *   - AlarmManager registrations are wiped on device reboot. The JSON store survives,
 *     so we walk it and re-register every future alarm.
 *
 * Actions handled:
 *   - BOOT_COMPLETED              — primary path (after user first-unlocks post-boot)
 *   - QUICKBOOT_POWERON           — HTC/Samsung quick-boot variant on older devices
 *   - MY_PACKAGE_REPLACED         — app upgrade: old PendingIntents invalid, re-register
 *   - TIME_SET / TIMEZONE_CHANGED — clock changed, relative trigger times must be re-pegged
 *
 * Past-due alarms (triggerAt < now) are marked MISSED and removed; we don't re-fire them.
 * Receiver onReceive has a ~10s budget; for PoC alarm counts this is more than enough.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.i(TAG, "onReceive action=$action")

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> rescheduleAll(context)

            else -> Log.w(TAG, "Unhandled action: $action")
        }
    }

    private fun rescheduleAll(context: Context) {
        val now = System.currentTimeMillis()
        val alarms = AlarmStore.getAll(context)
        Log.i(TAG, "Found ${alarms.size} alarms in store")

        var rescheduled = 0
        var missed = 0

        alarms.forEach { alarm ->
            if (alarm.triggerAtMillis < now) {
                Log.w(TAG, "MISSED id=${alarm.id} '${alarm.title}' scheduledAt=${alarm.triggerAtMillis} now=$now")
                AlarmStore.delete(context, alarm.id)
                missed++
            } else {
                // schedule() preserves snoozeCount + createdAt via existing-record lookup
                AlarmScheduler.schedule(context, alarm.id, alarm.triggerAtMillis, alarm.title)
                Log.i(TAG, "Rescheduled id=${alarm.id} '${alarm.title}' at=${alarm.triggerAtMillis}")
                rescheduled++
            }
        }

        Log.i(TAG, "Done: rescheduled=$rescheduled missed=$missed")
    }

    companion object {
        private const val TAG = "PoC.BootReceiver"
    }
}