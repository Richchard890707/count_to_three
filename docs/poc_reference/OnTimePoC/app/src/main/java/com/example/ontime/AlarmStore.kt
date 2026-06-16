package com.example.ontime

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.IOException

/**
 * S5 persistent alarm store. JSON file in app's internal storage.
 *
 * Robustness:
 *   - Atomic writes via temp file + rename
 *   - Corrupt JSON → log + treat as empty (does not crash app)
 *   - In-memory cache to reduce file I/O; @Synchronized for thread safety
 *
 * Same-process scope: AlarmService, AlarmReceiver, MainActivity, AlarmActivity all share.
 */
object AlarmStore {
    private const val TAG = "PoC.Store"
    private const val FILE_NAME = "alarms.json"

    private var cache: MutableMap<Int, AlarmData>? = null

    @Synchronized
    private fun ensureLoaded(context: Context) {
        if (cache != null) return
        cache = mutableMapOf()
        val file = File(context.filesDir, FILE_NAME)
        if (!file.exists()) {
            Log.i(TAG, "No store file yet; starting empty")
            return
        }
        try {
            val json = JSONObject(file.readText())
            val arr = json.getJSONArray("alarms")
            for (i in 0 until arr.length()) {
                val alarm = AlarmData.fromJson(arr.getJSONObject(i))
                cache!![alarm.id] = alarm
            }
            Log.i(TAG, "Loaded ${cache!!.size} alarms from disk")
        } catch (t: Throwable) {
            Log.e(TAG, "Corrupt store; treating as empty", t)
            cache = mutableMapOf()
        }
    }

    @Synchronized
    private fun writeToFile(context: Context) {
        val data = cache ?: return
        val arr = JSONArray()
        data.values.forEach { arr.put(it.toJson()) }
        val root = JSONObject().apply { put("alarms", arr) }
        val file = File(context.filesDir, FILE_NAME)
        val tmp = File(context.filesDir, "$FILE_NAME.tmp")
        try {
            tmp.writeText(root.toString(2))
            if (!tmp.renameTo(file)) {
                file.writeText(tmp.readText())
                tmp.delete()
            }
            Log.i(TAG, "Wrote ${data.size} alarms to ${file.absolutePath}")
        } catch (e: IOException) {
            Log.e(TAG, "Failed to write store", e)
        }
    }

    @Synchronized
    fun getAll(context: Context): List<AlarmData> {
        ensureLoaded(context)
        return cache!!.values.toList().sortedBy { it.triggerAtMillis }
    }

    @Synchronized
    fun getById(context: Context, id: Int): AlarmData? {
        ensureLoaded(context)
        return cache!![id]
    }

    @Synchronized
    fun save(context: Context, alarm: AlarmData) {
        ensureLoaded(context)
        cache!![alarm.id] = alarm
        writeToFile(context)
    }

    @Synchronized
    fun delete(context: Context, id: Int) {
        ensureLoaded(context)
        if (cache!!.remove(id) != null) writeToFile(context)
    }

    @Synchronized
    fun nextId(context: Context): Int {
        ensureLoaded(context)
        return (cache!!.keys.maxOrNull() ?: 0) + 1
    }
}