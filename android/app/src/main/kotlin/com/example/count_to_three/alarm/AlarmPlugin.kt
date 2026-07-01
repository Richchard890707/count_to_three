package com.example.count_to_three.alarm

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AlarmPlugin(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private var testPlayer: MediaPlayer? = null
    private var testVibrator: Vibrator? = null
    companion object {
        private const val METHOD_CHANNEL = "app.ontime/alarm"
        private const val EVENT_CHANNEL = "app.ontime/alarm_events"
    }

    init {
        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler(this)
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(AlarmEventBus)
        AlarmEngine.init(context)
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scheduleAlarm" -> {
                val args = call.arguments as Map<String, Any>
                AlarmEngine.scheduleAlarm(
                    context,
                    alarmId = (args["alarmId"] as Number).toInt(),
                    reminderId = args["reminderId"] as String,
                    title = args["title"] as String,
                    triggerAtMs = (args["triggerAtMs"] as Number).toLong(),
                    snoozeMinutes = (args["snoozeMinutes"] as? Number)?.toInt() ?: 5,
                    maxSnoozeCount = (args["maxSnoozeCount"] as? Number)?.toInt() ?: 3,
                    volumeRamp = args["volumeRamp"] as? Boolean ?: false,
                    vibrate = args["vibrate"] as? Boolean ?: true,
                    ringtoneUri = args["ringtoneUri"] as? String,
                )
                result.success(null)
            }
            "cancelAlarm" -> {
                val alarmId = (call.arguments as Number).toInt()
                // If the service is actively ringing this alarm, stop it properly
                // (teardown + Dismissed event). Otherwise just cancel the scheduled intent.
                if (!AlarmService.stopIfRinging(alarmId)) {
                    AlarmEngine.cancelAlarm(context, alarmId)
                }
                result.success(null)
            }
            "snoozeAlarm" -> {
                val alarmId = (call.arguments as Number).toInt()
                // If the service is actively ringing, route through handleSnooze
                // (teardown + reschedule + Snoozed event). Fallback keeps existing behaviour.
                if (!AlarmService.snoozeIfRinging(alarmId)) {
                    AlarmEngine.snoozeAlarm(context, alarmId)
                }
                result.success(null)
            }
            "getPendingAlarms" -> result.success(AlarmEngine.getPendingAlarms())
            "battery.isIgnoring" -> {
                val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
                result.success(pm.isIgnoringBatteryOptimizations(context.packageName))
            }
            "battery.requestIgnore" -> {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                result.success(null)
            }
            "alarm.canScheduleExact" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    result.success(am.canScheduleExactAlarms())
                } else {
                    result.success(true)
                }
            }
            "alarm.openExactAlarmSettings" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                        data = Uri.parse("package:${context.packageName}")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    context.startActivity(intent)
                }
                result.success(null)
            }
            "fullscreen.canUse" -> {
                if (Build.VERSION.SDK_INT >= 34) {
                    val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    result.success(nm.canUseFullScreenIntent())
                } else {
                    result.success(true)
                }
            }
            "fullscreen.openSettings" -> {
                if (Build.VERSION.SDK_INT >= 34) {
                    val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT).apply {
                        data = Uri.parse("package:${context.packageName}")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    context.startActivity(intent)
                }
                result.success(null)
            }
            "alarm.getRingtones" -> {
                val rm = RingtoneManager(context)
                rm.setType(RingtoneManager.TYPE_ALARM)
                val cursor = rm.cursor
                val list = mutableListOf<Map<String, String>>()
                while (cursor.moveToNext()) {
                    val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                    val uri = rm.getRingtoneUri(cursor.position).toString()
                    list.add(mapOf("title" to title, "uri" to uri))
                }
                cursor.close()
                result.success(list)
            }
            "alarm.getRingtoneName" -> {
                val uriStr = call.arguments as? String
                if (uriStr == null) { result.success(null); return }
                val ringtone = RingtoneManager.getRingtone(context, Uri.parse(uriStr))
                result.success(ringtone?.getTitle(context))
            }
            "alarm.testRing" -> {
                stopTestRing()
                val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                val ringtoneUri = args["ringtoneUri"] as? String
                val volumeRamp = args["volumeRamp"] as? Boolean ?: false
                val vibrate = args["vibrate"] as? Boolean ?: true
                val uri = if (ringtoneUri != null) {
                    try { Uri.parse(ringtoneUri) } catch (_: Exception) {
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    }
                } else {
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                }
                testPlayer = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    setDataSource(context, uri)
                    isLooping = false
                    setOnPreparedListener { player ->
                        player.setVolume(if (volumeRamp) 0.3f else 1f, if (volumeRamp) 0.3f else 1f)
                        player.start()
                    }
                    setOnCompletionListener { stopTestRing() }
                    prepareAsync()
                }
                if (vibrate) {
                    testVibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
                    } else {
                        @Suppress("DEPRECATION")
                        context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                    }
                    val pattern = longArrayOf(0, 400, 200, 400)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        testVibrator?.vibrate(VibrationEffect.createWaveform(pattern, -1))
                    } else {
                        @Suppress("DEPRECATION")
                        testVibrator?.vibrate(pattern, -1)
                    }
                }
                result.success(null)
            }
            "alarm.stopTestRing" -> {
                stopTestRing()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun stopTestRing() {
        testPlayer?.runCatching { stop(); release() }
        testPlayer = null
        testVibrator?.cancel()
        testVibrator = null
    }
}
