package com.example.ontime

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * S2 receiver: minimal handoff to AlarmService.
 *
 * The receiver no longer plays sound or posts notifications itself — those move into
 * AlarmService where they can outlive the 10s receiver window and survive process pressure.
 *
 * Starting an FGS from a BroadcastReceiver triggered by AlarmManager is an explicitly
 * allowed path under Android 14/15 background-start restrictions.
 */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(AlarmScheduler.EXTRA_ALARM_ID, -1)
        Log.i(TAG, "FIRED id=$alarmId action=${intent.action} at=${System.currentTimeMillis()}")

        val svcIntent = Intent(context, AlarmService::class.java).apply {
            putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(svcIntent)
            } else {
                context.startService(svcIntent)
            }
            Log.i(TAG, "startForegroundService dispatched")
        } catch (t: Throwable) {
            Log.e(TAG, "Failed to start AlarmService", t)
        }
    }

    companion object {
        private const val TAG = "PoC.Receiver"
    }
}