package com.example.count_to_three.alarm

import android.app.KeyguardManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import com.example.count_to_three.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : AppCompatActivity() {
    private val clockFmt = SimpleDateFormat("HH:mm", Locale.getDefault())
    private val clockHandler = Handler(Looper.getMainLooper())
    private val clockTick = object : Runnable {
        override fun run() {
            findViewById<TextView>(R.id.tv_clock)?.text = clockFmt.format(Date())
            clockHandler.postDelayed(this, 1_000)
        }
    }
    private var alarmId = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        alarmId = intent.getIntExtra("alarm_id", -1)
        applyLockScreenFlags()
        setContentView(R.layout.activity_alarm)
        AlarmStore.init(this)
        refreshTitle()
        clockTick.run()

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() { /* block back */ }
        })

        findViewById<Button>(R.id.btn_stop).setOnClickListener {
            sendToService(AlarmService.ACTION_STOP)
        }
        findViewById<Button>(R.id.btn_snooze).setOnClickListener {
            sendToService(AlarmService.ACTION_SNOOZE)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        alarmId = intent.getIntExtra("alarm_id", -1)
        AlarmStore.init(this)
        refreshTitle()
    }

    override fun onDestroy() {
        clockHandler.removeCallbacks(clockTick)
        super.onDestroy()
    }

    private fun applyLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            (getSystemService(KEYGUARD_SERVICE) as KeyguardManager)
                .requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    private fun refreshTitle() {
        val title = AlarmStore.get(alarmId)?.title ?: "鬧鐘"
        findViewById<TextView>(R.id.tv_alarm_title)?.text = title
    }

    private fun sendToService(action: String) {
        startService(Intent(this, AlarmService::class.java).apply {
            this.action = action
            putExtra("alarm_id", alarmId)
        })
        finishAndRemoveTask()
    }
}
