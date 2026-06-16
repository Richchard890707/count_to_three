package com.example.count_to_three.alarm

import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import com.example.count_to_three.alarm.model.AlarmEvent

class AlarmService : Service() {
    companion object {
        const val ACTION_FIRE = "action_fire"
        const val ACTION_STOP = "action_stop"
        const val ACTION_SNOOZE = "action_snooze"
        private const val AUTO_STOP_MS = 5 * 60 * 1000L
        private const val WAKE_LOCK_TAG = "count_to_three:alarm"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var currentAlarmId = -1
    private val handler = Handler(Looper.getMainLooper())

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        NotificationHelper.createChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_FIRE -> handleFire(intent)
            ACTION_STOP -> handleStop(intent)
            ACTION_SNOOZE -> handleSnooze(intent)
        }
        return START_NOT_STICKY
    }

    private fun handleFire(intent: Intent) {
        val alarmId = intent.getIntExtra("alarm_id", -1)
        if (alarmId == -1) { stopSelf(); return }
        AlarmStore.init(this)
        val alarm = AlarmStore.get(alarmId) ?: run { stopSelf(); return }
        currentAlarmId = alarmId

        acquireWakeLock()
        startForeground(
            NotificationHelper.NOTIFICATION_ID,
            NotificationHelper.buildFiringNotification(this, alarm.title, alarmId),
        )
        playRingtone()
        AlarmEventBus.emit(AlarmEvent.Fired(alarmId, alarm.reminderId, alarm.title))
        handler.postDelayed({ autoStop(alarmId) }, AUTO_STOP_MS)
    }

    private fun handleStop(intent: Intent) {
        val alarmId = intent.getIntExtra("alarm_id", -1)
        AlarmStore.init(this)
        AlarmStore.get(alarmId)?.let {
            AlarmEventBus.emit(AlarmEvent.Dismissed(alarmId, it.reminderId))
            AlarmStore.remove(this, alarmId)
        }
        teardown()
    }

    private fun handleSnooze(intent: Intent) {
        val alarmId = intent.getIntExtra("alarm_id", -1)
        AlarmStore.init(this)
        val alarm = AlarmStore.get(alarmId) ?: run { teardown(); return }

        if (alarm.snoozeCount >= alarm.maxSnoozeCount) {
            AlarmEventBus.emit(AlarmEvent.Dismissed(alarmId, alarm.reminderId, auto = true))
            AlarmStore.remove(this, alarmId)
            teardown()
            return
        }

        val snoozed = alarm.copy(
            snoozeCount = alarm.snoozeCount + 1,
            scheduledAt = System.currentTimeMillis() + alarm.snoozeMinutes * 60_000L,
        )
        AlarmStore.put(this, snoozed)
        AlarmScheduler.schedule(this, snoozed)
        AlarmEventBus.emit(AlarmEvent.Snoozed(alarmId, alarm.reminderId, snoozed.snoozeCount))
        teardown()
    }

    private fun autoStop(alarmId: Int) {
        if (currentAlarmId != alarmId) return
        AlarmStore.init(this)
        AlarmStore.get(alarmId)?.let {
            AlarmEventBus.emit(AlarmEvent.Dismissed(alarmId, it.reminderId, auto = true))
            AlarmStore.remove(this, alarmId)
        }
        teardown()
    }

    private fun playRingtone() {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        mediaPlayer = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            setDataSource(this@AlarmService, uri)
            isLooping = true
            setOnPreparedListener { it.start() }
            prepareAsync()
        }
    }

    private fun teardown() {
        handler.removeCallbacksAndMessages(null)
        mediaPlayer?.runCatching { stop(); release() }
        mediaPlayer = null
        wakeLock?.runCatching { if (isHeld) release() }
        wakeLock = null
        @Suppress("DEPRECATION")
        stopForeground(true)
        stopSelf()
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG).apply {
            acquire(AUTO_STOP_MS + 10_000L)
        }
    }

    override fun onDestroy() {
        teardown()
        super.onDestroy()
    }
}
