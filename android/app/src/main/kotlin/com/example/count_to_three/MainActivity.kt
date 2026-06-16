package com.example.count_to_three

import com.example.count_to_three.alarm.AlarmPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AlarmPlugin(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }
}
