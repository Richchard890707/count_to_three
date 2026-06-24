package com.example.count_to_three.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.count_to_three.MainActivity
import com.example.count_to_three.R
import java.util.concurrent.TimeUnit

class AlarmWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == HOME_WIDGET_UPDATE_ACTION) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, AlarmWidgetProvider::class.java)
            )
            for (id in ids) updateWidget(context, manager, id)
        }
    }

    companion object {
        const val HOME_WIDGET_UPDATE_ACTION = "es.antonborri.home_widget.action.UPDATE_WIDGET"

        fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val prefs = context.getSharedPreferences(
                "${context.packageName}.home_widget", Context.MODE_PRIVATE
            )

            val time  = prefs.getString("nextAlarmTime", null)
            val title = prefs.getString("nextAlarmTitle", null)
            val ms    = prefs.getLong("nextAlarmMs", -1L)

            val views = RemoteViews(context.packageName, R.layout.alarm_widget_layout)

            if (time != null && title != null) {
                views.setTextViewText(R.id.widget_time, time)
                views.setTextViewText(R.id.widget_title, title)
                views.setTextViewText(R.id.widget_countdown, countdown(ms))
            } else {
                views.setTextViewText(R.id.widget_time, "--:--")
                views.setTextViewText(R.id.widget_title, "無預排鬧鐘")
                views.setTextViewText(R.id.widget_countdown, "")
            }

            // Tap widget → open app
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            manager.updateAppWidget(widgetId, views)
        }

        private fun countdown(ms: Long): String {
            if (ms <= 0L) return ""
            val remaining = ms - System.currentTimeMillis()
            if (remaining <= 0L) return ""
            val h = TimeUnit.MILLISECONDS.toHours(remaining)
            val m = TimeUnit.MILLISECONDS.toMinutes(remaining) % 60
            return when {
                h > 0  -> "還有 ${h} 小時 ${m} 分"
                m > 0  -> "還有 ${m} 分鐘"
                else   -> "即將響起"
            }
        }
    }
}
