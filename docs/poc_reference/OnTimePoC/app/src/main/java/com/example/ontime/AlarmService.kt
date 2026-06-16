package com.example.ontime

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log

class AlarmService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())
    private var currentAlarmId: Int = -1

    private val autoStopRunnable = Runnable {
        Log.i(TAG, "Auto-stop after ${AUTO_STOP_MS / 1000}s id=$currentAlarmId → AUTO_DISMISSED")
        AlarmStore.delete(this, currentAlarmId)
        stopSelfFully()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId = intent?.getIntExtra(AlarmScheduler.EXTRA_ALARM_ID, -1) ?: -1
        val action = intent?.action
        Log.i(TAG, "onStartCommand id=$alarmId action=$action")
        currentAlarmId = alarmId

        when (action) {
            ACTION_STOP -> { handleStop(alarmId); return START_NOT_STICKY }
            ACTION_SNOOZE -> { handleSnooze(alarmId); return START_NOT_STICKY }
            else -> { handleFire(alarmId); return START_NOT_STICKY }
        }
    }

    private fun handleFire(alarmId: Int) {
        val alarm = AlarmStore.getById(this, alarmId)
        if (alarm == null) {
            Log.w(TAG, "Fire for unknown alarm id=$alarmId (cancelled?)")
            stopSelf()
            return
        }
        if (alarm.snoozeCount > MAX_SNOOZE_COUNT) {
            Log.w(TAG, "Snooze cap exceeded (count=${alarm.snoozeCount}) → AUTO_DISMISSED")
            AlarmStore.delete(this, alarmId)
            stopSelf()
            return
        }

        val notification = NotificationHelper.buildForegroundAlarmNotification(
            this, alarmId, alarm.title
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NotificationHelper.FGS_NOTIF_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NotificationHelper.FGS_NOTIF_ID, notification)
        }
        acquireWakeLock()
        startRingtone()
        handler.removeCallbacks(autoStopRunnable)
        handler.postDelayed(autoStopRunnable, AUTO_STOP_MS)

        Log.i(TAG, "FIRING id=$alarmId title='${alarm.title}' snoozes=${alarm.snoozeCount}")
    }

    private fun handleStop(alarmId: Int) {
        Log.i(TAG, "STOP id=$alarmId → DISMISSED")
        AlarmStore.delete(this, alarmId)
        stopSelfFully()
    }

    private fun handleSnooze(alarmId: Int) {
        val current = AlarmStore.getById(this, alarmId)
        if (current == null) {
            Log.w(TAG, "SNOOZE for unknown alarm id=$alarmId")
            stopSelfFully()
            return
        }
        if (current.snoozeCount + 1 > MAX_SNOOZE_COUNT) {
            Log.w(TAG, "Snooze cap reached (would be ${current.snoozeCount + 1}) → AUTO_DISMISSED")
            AlarmStore.delete(this, alarmId)
            stopSelfFully()
            return
        }
        AlarmScheduler.snooze(this, alarmId, SNOOZE_DURATION_MS)
        Log.i(TAG, "SNOOZED id=$alarmId")
        stopSelfFully()
    }

    private fun stopSelfFully() {
        handler.removeCallbacks(autoStopRunnable)
        stopRingtone()
        releaseWakeLock()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    override fun onDestroy() {
        Log.i(TAG, "onDestroy id=$currentAlarmId")
        handler.removeCallbacks(autoStopRunnable)
        stopRingtone()
        releaseWakeLock()
        super.onDestroy()
    }

    private fun startRingtone() {
        try {
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION) ?: return
            val attrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(attrs)
                setDataSource(this@AlarmService, uri)
                isLooping = true
                setOnPreparedListener {
                    Log.i(TAG, "MediaPlayer prepared, starting playback")
                    it.start()
                }
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error what=$what extra=$extra"); false
                }
                prepareAsync()
            }
        } catch (t: Throwable) {
            Log.e(TAG, "startRingtone failed", t)
        }
    }

    private fun stopRingtone() {
        try {
            mediaPlayer?.apply { if (isPlaying) stop(); release() }
        } catch (t: Throwable) {
            Log.e(TAG, "stopRingtone failed", t)
        } finally {
            mediaPlayer = null
        }
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "OnTime:AlarmService"
        ).apply { acquire(AUTO_STOP_MS + 10_000L) }
    }

    private fun releaseWakeLock() {
        wakeLock?.let { if (it.isHeld) try { it.release() } catch (_: Throwable) {} }
        wakeLock = null
    }

    companion object {
        private const val TAG = "PoC.Service"
        const val ACTION_STOP = "com.example.ontime.ACTION_STOP"
        const val ACTION_SNOOZE = "com.example.ontime.ACTION_SNOOZE"
        private const val AUTO_STOP_MS = 5 * 60 * 1000L
        private const val SNOOZE_DURATION_MS = 60 * 1000L
        private const val MAX_SNOOZE_COUNT = 3
    }
}