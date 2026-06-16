package com.example.count_to_three.alarm

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AlarmPlugin(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
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
                )
                result.success(null)
            }
            "cancelAlarm" -> {
                AlarmEngine.cancelAlarm(context, (call.arguments as Number).toInt())
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
            else -> result.notImplemented()
        }
    }
}
