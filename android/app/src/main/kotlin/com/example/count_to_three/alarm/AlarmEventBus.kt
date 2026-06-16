package com.example.count_to_three.alarm

import android.os.Handler
import android.os.Looper
import com.example.count_to_three.alarm.model.AlarmEvent
import io.flutter.plugin.common.EventChannel

object AlarmEventBus : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val pending = mutableListOf<AlarmEvent>()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        val snapshot = pending.toList()
        pending.clear()
        snapshot.forEach { mainHandler.post { events?.success(it.toMap()) } }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(event: AlarmEvent) {
        val s = sink
        if (s != null) {
            mainHandler.post { s.success(event.toMap()) }
        } else {
            pending.add(event)
        }
    }
}
