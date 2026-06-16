package com.example.ontime

import org.json.JSONObject

/**
 * S5 alarm data model. Persisted to JSON; minimal so file stays human-readable.
 *
 * "State" is implicit:
 *   - In store    → SCHEDULED (or SNOOZED if snoozeCount > 0)
 *   - Removed     → DISMISSED / AUTO_DISMISSED
 *   - FIRING is transient and tracked only by AlarmService
 */
data class AlarmData(
    val id: Int,
    val title: String,
    val triggerAtMillis: Long,
    val snoozeCount: Int = 0,
    val createdAt: Long = System.currentTimeMillis()
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("title", title)
        put("triggerAtMillis", triggerAtMillis)
        put("snoozeCount", snoozeCount)
        put("createdAt", createdAt)
    }

    companion object {
        fun fromJson(json: JSONObject): AlarmData = AlarmData(
            id = json.getInt("id"),
            title = json.optString("title", "Alarm"),
            triggerAtMillis = json.getLong("triggerAtMillis"),
            snoozeCount = json.optInt("snoozeCount", 0),
            createdAt = json.optLong("createdAt", System.currentTimeMillis())
        )
    }
}