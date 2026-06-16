package com.example.count_to_three.alarm

import android.content.Context
import com.example.count_to_three.alarm.model.AlarmData
import org.json.JSONArray
import java.io.File

object AlarmStore {
    private const val FILE_NAME = "alarm_store.json"
    private val cache = mutableMapOf<Int, AlarmData>()
    private var initialized = false

    @Synchronized
    fun init(context: Context) {
        if (initialized) return
        initialized = true
        loadFromDisk(context)
    }

    @Synchronized
    fun put(context: Context, alarm: AlarmData) {
        cache[alarm.id] = alarm
        saveToDisk(context)
    }

    @Synchronized
    fun get(id: Int): AlarmData? = cache[id]

    @Synchronized
    fun remove(context: Context, id: Int) {
        cache.remove(id)
        saveToDisk(context)
    }

    @Synchronized
    fun getAll(): List<AlarmData> = cache.values.toList()

    private fun loadFromDisk(context: Context) {
        try {
            val file = storeFile(context)
            if (!file.exists()) return
            val arr = JSONArray(file.readText())
            repeat(arr.length()) { i ->
                val alarm = AlarmData.fromJson(arr.getJSONObject(i))
                cache[alarm.id] = alarm
            }
        } catch (_: Exception) {
            cache.clear()
        }
    }

    private fun saveToDisk(context: Context) {
        val arr = JSONArray()
        cache.values.forEach { arr.put(it.toJson()) }
        val tmp = File(context.filesDir, "$FILE_NAME.tmp")
        tmp.writeText(arr.toString())
        tmp.renameTo(storeFile(context))
    }

    private fun storeFile(context: Context) = File(context.filesDir, FILE_NAME)
}
