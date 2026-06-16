package com.example.count_to_three.alarm.model

import org.json.JSONObject

data class AlarmData(
    val id: Int,
    val reminderId: String,
    val title: String,
    val scheduledAt: Long,
    val snoozeCount: Int = 0,
    val snoozeMinutes: Int = 5,
    val maxSnoozeCount: Int = 3,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("reminderId", reminderId)
        put("title", title)
        put("scheduledAt", scheduledAt)
        put("snoozeCount", snoozeCount)
        put("snoozeMinutes", snoozeMinutes)
        put("maxSnoozeCount", maxSnoozeCount)
    }

    companion object {
        fun fromJson(json: JSONObject) = AlarmData(
            id = json.getInt("id"),
            reminderId = json.getString("reminderId"),
            title = json.getString("title"),
            scheduledAt = json.getLong("scheduledAt"),
            snoozeCount = json.optInt("snoozeCount", 0),
            snoozeMinutes = json.optInt("snoozeMinutes", 5),
            maxSnoozeCount = json.optInt("maxSnoozeCount", 3),
        )
    }
}
