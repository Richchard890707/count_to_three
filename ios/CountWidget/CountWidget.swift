import WidgetKit
import SwiftUI

// MARK: - Data model

struct NextAlarm {
    let title: String
    let time: String  // "HH:mm"
    let ms: Int?      // epoch ms — nil when no alarm

    static let none = NextAlarm(title: "無預排鬧鐘", time: "--:--", ms: nil)
}

// MARK: - Timeline provider

struct AlarmEntry: TimelineEntry {
    let date: Date
    let alarm: NextAlarm
}

struct AlarmProvider: TimelineProvider {
    private let appGroup = "group.com.example.countToThree"

    func placeholder(in context: Context) -> AlarmEntry {
        AlarmEntry(date: Date(), alarm: NextAlarm(title: "早安起床", time: "07:00", ms: nil))
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
        completion(AlarmEntry(date: Date(), alarm: readAlarm()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlarmEntry>) -> Void) {
        let alarm = readAlarm()
        let entry = AlarmEntry(date: Date(), alarm: alarm)

        // Refresh in 15 min, or 1 min after the alarm fires
        var refreshDate: Date
        if let ms = alarm.ms {
            let fireDate = Date(timeIntervalSince1970: Double(ms) / 1000.0)
            refreshDate = min(fireDate.addingTimeInterval(60), Date().addingTimeInterval(15 * 60))
        } else {
            refreshDate = Date().addingTimeInterval(15 * 60)
        }

        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func readAlarm() -> NextAlarm {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return .none }
        guard let time = defaults.string(forKey: "nextAlarmTime"),
              let title = defaults.string(forKey: "nextAlarmTitle") else { return .none }
        let ms = defaults.object(forKey: "nextAlarmMs") as? Int
        return NextAlarm(title: title, time: time, ms: ms)
    }
}

// MARK: - Widget view

struct AlarmWidgetView: View {
    let entry: AlarmEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallAlarmView(alarm: entry.alarm)
        case .systemMedium:
            MediumAlarmView(alarm: entry.alarm)
        default:
            SmallAlarmView(alarm: entry.alarm)
        }
    }
}

struct SmallAlarmView: View {
    let alarm: NextAlarm

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(Color(red: 0.898, green: 0.224, blue: 0.208))
                    .font(.caption)
                Spacer()
            }
            Spacer()
            Text(alarm.time)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(alarm.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if let countdown = countdown(alarm) {
                Text(countdown)
                    .font(.caption2)
                    .foregroundStyle(Color(red: 0.898, green: 0.224, blue: 0.208))
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct MediumAlarmView: View {
    let alarm: NextAlarm

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color(red: 0.898, green: 0.224, blue: 0.208))
            VStack(alignment: .leading, spacing: 4) {
                Text("下一個鬧鐘")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(alarm.time)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                Text(alarm.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let countdown = countdown(alarm) {
                    Text(countdown)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.898, green: 0.224, blue: 0.208))
                }
            }
            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

private func countdown(_ alarm: NextAlarm) -> String? {
    guard let ms = alarm.ms else { return nil }
    let secs = Int(Date(timeIntervalSince1970: Double(ms) / 1000.0).timeIntervalSinceNow)
    guard secs > 0 else { return nil }
    let h = secs / 3600
    let m = (secs % 3600) / 60
    if h > 0 { return "還有 \(h) 小時 \(m) 分" }
    if m > 0 { return "還有 \(m) 分鐘" }
    return "即將響起"
}

// MARK: - Widget bundle

@main
struct CountWidget: Widget {
    let kind = "CountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlarmProvider()) { entry in
            AlarmWidgetView(entry: entry)
        }
        .configurationDisplayName("Count to Three")
        .description("顯示下一個鬧鐘時間")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
