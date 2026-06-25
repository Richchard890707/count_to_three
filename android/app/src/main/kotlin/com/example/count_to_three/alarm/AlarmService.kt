package com.example.count_to_three.alarm

import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import com.example.count_to_three.alarm.model.AlarmEvent

class AlarmService : Service() {
    companion object {
        const val ACTION_FIRE = "action_fire"
        const val ACTION_STOP = "action_stop"
        const val ACTION_SNOOZE = "action_snooze"
        private const val AUTO_STOP_MS = 5 * 60 * 1000L
        private const val WAKE_LOCK_TAG = "count_to_three:alarm"

        // Direct reference so AlarmActivity can call stop/snooze without startService()
        // (MIUI blocks startService() from lock-screen activities on some devices).
        @Volatile private var instance: AlarmService? = null

        fun stopAlarm(context: android.content.Context, alarmId: Int) {
            val svc = instance
            if (svc != null) {
                svc.handler.post { svc.handleStop(alarmId) }
            } else {
                // Fallback: service might have already been killed; cancel via intent.
                context.startService(
                    android.content.Intent(context, AlarmService::class.java).apply {
                        action = ACTION_STOP
                        putExtra("alarm_id", alarmId)
                    }
                )
            }
        }

        fun snoozeAlarm(context: android.content.Context, alarmId: Int) {
            val svc = instance
            if (svc != null) {
                svc.handler.post { svc.handleSnooze(alarmId) }
            } else {
                context.startService(
                    android.content.Intent(context, AlarmService::class.java).apply {
                        action = ACTION_SNOOZE
                        putExtra("alarm_id", alarmId)
                    }
                )
            }
        }
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var currentAlarmId = -1
    private val handler = Handler(Looper.getMainLooper())
    private var volumeRampRunnable: Runnable? = null
    private var autoStopRunnable: Runnable? = null
    private var notifSwitchRunnable: Runnable? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        NotificationHelper.createChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_FIRE -> handleFire(intent)
            ACTION_STOP -> handleStop(intent.getIntExtra("alarm_id", -1))
            ACTION_SNOOZE -> handleSnooze(intent.getIntExtra("alarm_id", -1))
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

        // Step 1: post a high-priority fullScreenIntent notification for the brief moment
        // needed to pierce the lock screen on devices that block startActivity() from services.
        startForeground(
            NotificationHelper.NOTIFICATION_ID,
            NotificationHelper.buildFullScreenTrigger(this, alarm.title, alarmId),
        )

        // Step 2: launch AlarmActivity directly — avoids heads-up notification entirely
        // on devices that honour activity starts from AlarmManager-triggered services.
        try {
            startActivity(
                android.content.Intent(this, AlarmActivity::class.java).apply {
                    flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or
                            android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("alarm_id", alarmId)
                }
            )
        } catch (_: Exception) { /* startActivity blocked — fullScreenIntent above will handle it */ }

        // Step 3: fallback — if AlarmActivity never shows up (BAL blocked on Android 15 with
        // screen on), replace the high-priority trigger notification with a silent ongoing one
        // after 10 s.  When AlarmActivity does start, it replaces the notification itself
        // immediately (so there is no visible 10 s window of heads-up in the normal case).
        val notifSwitch = Runnable {
            val nm = getSystemService(NOTIFICATION_SERVICE) as android.app.NotificationManager
            nm.notify(
                NotificationHelper.NOTIFICATION_ID,
                NotificationHelper.buildFiringNotification(this, alarm.title, alarmId),
            )
        }
        notifSwitchRunnable = notifSwitch
        handler.postDelayed(notifSwitch, 10_000)

        playRingtone(alarm.volumeRamp, alarm.ringtoneUri)
        if (alarm.vibrate) startVibration()
        AlarmEventBus.emit(
            AlarmEvent.Fired(alarmId, alarm.reminderId, alarm.title, alarm.scheduledAt, alarm.snoozeCount, alarm.maxSnoozeCount)
        )
        val autoStop = Runnable { autoStop(alarmId) }
        autoStopRunnable = autoStop
        handler.postDelayed(autoStop, AUTO_STOP_MS)
    }

    private fun handleStop(alarmId: Int) {
        AlarmStore.init(this)
        AlarmStore.get(alarmId)?.let {
            AlarmEventBus.emit(AlarmEvent.Dismissed(alarmId, it.reminderId, it.scheduledAt))
            AlarmStore.remove(this, alarmId)
        }
        teardown()
    }

    private fun handleSnooze(alarmId: Int) {
        AlarmStore.init(this)
        val alarm = AlarmStore.get(alarmId) ?: run { teardown(); return }

        if (alarm.snoozeCount >= alarm.maxSnoozeCount) {
            AlarmEventBus.emit(AlarmEvent.Dismissed(alarmId, alarm.reminderId, alarm.scheduledAt, auto = true))
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
        AlarmEventBus.emit(AlarmEvent.Snoozed(alarmId, alarm.reminderId, alarm.scheduledAt, snoozed.snoozeCount))
        teardown()
    }

    private fun autoStop(alarmId: Int) {
        if (currentAlarmId != alarmId) return
        AlarmStore.init(this)
        AlarmStore.get(alarmId)?.let {
            AlarmEventBus.emit(AlarmEvent.Dismissed(alarmId, it.reminderId, it.scheduledAt, auto = true))
            AlarmStore.remove(this, alarmId)
        }
        teardown()
    }

    private fun playRingtone(volumeRamp: Boolean, ringtoneUri: String?) {
        val uri = if (ringtoneUri != null) {
            try { Uri.parse(ringtoneUri) } catch (_: Exception) {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            }
        } else {
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        }
        mediaPlayer = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            setDataSource(this@AlarmService, uri)
            isLooping = true
            setOnPreparedListener { player ->
                if (volumeRamp) {
                    player.setVolume(0.05f, 0.05f)
                    startVolumeRamp(player)
                } else {
                    player.setVolume(1f, 1f)
                }
                player.start()
            }
            prepareAsync()
        }
    }

    // Ramps from 0.05 to 1.0 over ~30 seconds (one step per second).
    private fun startVolumeRamp(player: MediaPlayer) {
        var volume = 0.05f
        val step = (1f - volume) / 30f
        val runnable = object : Runnable {
            override fun run() {
                if (mediaPlayer == null) return
                volume = (volume + step).coerceAtMost(1f)
                player.setVolume(volume, volume)
                if (volume < 1f) handler.postDelayed(this, 1_000L)
                else volumeRampRunnable = null
            }
        }
        volumeRampRunnable = runnable
        handler.postDelayed(runnable, 1_000L)
    }

    private fun startVibration() {
        val pattern = longArrayOf(0, 800, 400, 800, 400)
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    private fun teardown() {
        volumeRampRunnable?.let { handler.removeCallbacks(it) }
        volumeRampRunnable = null
        autoStopRunnable?.let { handler.removeCallbacks(it) }
        autoStopRunnable = null
        notifSwitchRunnable?.let { handler.removeCallbacks(it) }
        notifSwitchRunnable = null
        mediaPlayer?.runCatching { stop(); release() }
        mediaPlayer = null
        vibrator?.cancel()
        vibrator = null
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
        instance = null
        teardown()
        super.onDestroy()
    }
}
