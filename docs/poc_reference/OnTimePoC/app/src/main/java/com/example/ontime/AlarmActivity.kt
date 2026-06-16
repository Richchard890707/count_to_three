package com.example.ontime

import android.app.KeyguardManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : ComponentActivity() {
    private val clockHandler = Handler(Looper.getMainLooper())
    private val clockUpdater = object : Runnable {
        override fun run() {
            updateClock()
            clockHandler.postDelayed(this, 1000L)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            getSystemService(KeyguardManager::class.java)?.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        setContentView(R.layout.activity_alarm)

        val alarmId = intent.getIntExtra(AlarmScheduler.EXTRA_ALARM_ID, -1)
        val stored = AlarmStore.getById(this, alarmId)
        Log.i(TAG, "onCreate id=$alarmId title='${stored?.title}' snoozes=${stored?.snoozeCount}")

        findViewById<TextView>(R.id.alarmTitle).text = stored?.title ?: "OnTime Alarm"
        findViewById<TextView>(R.id.alarmSubtitle).text =
            "id=$alarmId" + if ((stored?.snoozeCount ?: 0) > 0) " · snoozed ${stored?.snoozeCount}x" else ""
        updateClock()

        findViewById<Button>(R.id.stopButton).setOnClickListener {
            Log.i(TAG, "STOP tapped id=$alarmId")
            dispatch(AlarmService.ACTION_STOP, alarmId)
            finishAndRemoveTask()
        }

        findViewById<Button>(R.id.snoozeButton).setOnClickListener {
            Log.i(TAG, "SNOOZE tapped id=$alarmId")
            dispatch(AlarmService.ACTION_SNOOZE, alarmId)
            finishAndRemoveTask()
        }

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                Log.i(TAG, "Back press blocked")
            }
        })
    }

    override fun onResume() {
        super.onResume()
        clockHandler.post(clockUpdater)
    }

    override fun onPause() {
        clockHandler.removeCallbacks(clockUpdater)
        super.onPause()
    }

    private fun dispatch(action: String, alarmId: Int) {
        val intent = Intent(this, AlarmService::class.java).apply {
            this.action = action
            putExtra(AlarmScheduler.EXTRA_ALARM_ID, alarmId)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(intent)
        else startService(intent)
    }

    private fun updateClock() {
        findViewById<TextView>(R.id.alarmClock)?.text =
            CLOCK_FMT.format(Date(System.currentTimeMillis()))
    }

    companion object {
        private const val TAG = "PoC.AlarmActivity"
        private val CLOCK_FMT = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
    }
}