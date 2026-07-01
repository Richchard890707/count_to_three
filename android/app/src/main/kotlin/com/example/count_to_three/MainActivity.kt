package com.example.count_to_three

import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.example.count_to_three.alarm.AlarmPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private var pendingPickResult: MethodChannel.Result? = null
    private lateinit var pickFileLauncher: ActivityResultLauncher<Array<String>>

    override fun onCreate(savedInstanceState: Bundle?) {
        // Must register ActivityResultLauncher before super.onCreate
        pickFileLauncher = registerForActivityResult(
            ActivityResultContracts.OpenDocument()
        ) { uri: Uri? ->
            val pending = pendingPickResult ?: return@registerForActivityResult
            pendingPickResult = null
            if (uri == null) {
                pending.success(null)
                return@registerForActivityResult
            }
            try {
                val content = contentResolver.openInputStream(uri)
                    ?.bufferedReader()?.use { it.readText() }
                pending.success(content)
            } catch (e: Exception) {
                pending.error("READ_ERROR", e.message, null)
            }
        }
        super.onCreate(savedInstanceState)

        if (intent?.action == "ALARM_RING") {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
            } else {
                @Suppress("DEPRECATION")
                window.addFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                )
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AlarmPlugin(applicationContext, flutterEngine.dartExecutor.binaryMessenger)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ontime/data")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFile" -> {
                        pendingPickResult = result
                        pickFileLauncher.launch(arrayOf("application/json", "*/*"))
                    }
                    else -> result.notImplemented()
                }
            }

        // scenario_timer: show the timer over the lock screen and keep the
        // screen on, so 做完這組/我好了 are tappable without unlocking.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ontime/timer")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setLockScreenMode" -> {
                        val enabled = call.arguments as? Boolean ?: false
                        runOnUiThread { setLockScreenMode(enabled) }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setLockScreenMode(enabled: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(enabled)
            setTurnScreenOn(enabled)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (enabled) window.addFlags(flags) else window.clearFlags(flags)
        }
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }
}
