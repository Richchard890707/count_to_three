package com.example.ontime

import android.Manifest
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.LayoutInflater
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : ComponentActivity() {

    private lateinit var statusView: TextView
    private lateinit var alarmListContainer: LinearLayout

    private val notificationPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            Log.i(TAG, "POST_NOTIFICATIONS granted=$granted")
            statusView.text = buildPermissionSummary()
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        NotificationHelper.ensureChannel(this)

        statusView = findViewById(R.id.statusText)
        alarmListContainer = findViewById(R.id.alarmListContainer)

        findViewById<Button>(R.id.scheduleButton).setOnClickListener {
            if (!ensurePermissions()) return@setOnClickListener
            scheduleNewAlarm()
        }
        findViewById<Button>(R.id.permissionButton).setOnClickListener {
            ensurePermissions(force = true)
            statusView.text = buildPermissionSummary()
        }
    }

    override fun onResume() {
        super.onResume()
        statusView.text = buildPermissionSummary()
        refreshAlarmList()
    }

    private fun scheduleNewAlarm() {
        val id = AlarmStore.nextId(this)
        val triggerAt = System.currentTimeMillis() + ALARM_DELAY_MS
        val title = "Alarm $id"
        AlarmScheduler.schedule(this, id, triggerAt, title)
        Toast.makeText(
            this,
            "$title scheduled @ ${HMS.format(Date(triggerAt))}",
            Toast.LENGTH_SHORT
        ).show()
        refreshAlarmList()
    }

    private fun refreshAlarmList() {
        val alarms = AlarmStore.getAll(this)
        alarmListContainer.removeAllViews()

        if (alarms.isEmpty()) {
            val tv = TextView(this).apply {
                text = "(no alarms)"
                setTextColor(0xFF9CA3AF.toInt())
                textSize = 14f
                setPadding(0, 24, 0, 24)
            }
            alarmListContainer.addView(tv)
            return
        }

        val inflater = LayoutInflater.from(this)
        alarms.forEach { alarm ->
            val row = inflater.inflate(R.layout.item_alarm, alarmListContainer, false)
            row.findViewById<TextView>(R.id.itemTitle).text = alarm.title
            row.findViewById<TextView>(R.id.itemTime).text =
                "${HMS.format(Date(alarm.triggerAtMillis))} — ${formatRelative(alarm.triggerAtMillis)}"
            row.findViewById<TextView>(R.id.itemMeta).text = buildString {
                append("id=${alarm.id}")
                if (alarm.snoozeCount > 0) append(" · snoozed ${alarm.snoozeCount}x")
            }
            row.findViewById<Button>(R.id.itemCancel).setOnClickListener {
                AlarmScheduler.cancel(this, alarm.id)
                refreshAlarmList()
            }
            alarmListContainer.addView(row)
        }
    }

    private fun formatRelative(triggerAt: Long): String {
        val deltaSec = (triggerAt - System.currentTimeMillis()) / 1000
        if (deltaSec <= 0) return "now"
        if (deltaSec < 60) return "in ${deltaSec}s"
        val min = deltaSec / 60
        if (min < 60) return "in ${min}m"
        return "in ${min / 60}h${min % 60}m"
    }

    private fun ensurePermissions(force: Boolean = false): Boolean {
        var allOk = true

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                notificationPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                allOk = false
                if (!force) return false
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            if (!am.canScheduleExactAlarms()) {
                Toast.makeText(this, "Grant Alarms & reminders permission", Toast.LENGTH_LONG).show()
                try {
                    startActivity(
                        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                            data = Uri.fromParts("package", packageName, null)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )
                } catch (t: Throwable) {
                    Log.e(TAG, "Cannot open exact-alarm settings", t)
                }
                allOk = false
            }
        }
        return allOk
    }

    private fun buildPermissionSummary(): String {
        val notif = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else true
        val exact = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
        } else true
        return "Notifications: ${if (notif) "OK" else "MISSING"}   ExactAlarm: ${if (exact) "OK" else "MISSING"}"
    }

    companion object {
        private const val TAG = "PoC.Main"
        private const val ALARM_DELAY_MS = 30 * 60 * 1000L
        private val HMS = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
    }
}