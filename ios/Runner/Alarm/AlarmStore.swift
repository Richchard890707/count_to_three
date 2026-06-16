import Foundation

final class AlarmStore {
    static let shared = AlarmStore()
    private var cache: [Int: AlarmData] = [:]
    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("alarm_store.json")
    }()

    private init() { loadFromDisk() }

    func put(_ alarm: AlarmData) {
        cache[alarm.id] = alarm
        saveToDisk()
    }

    func get(_ id: Int) -> AlarmData? { cache[id] }

    func remove(_ id: Int) {
        cache.removeValue(forKey: id)
        saveToDisk()
    }

    func getAll() -> [AlarmData] { Array(cache.values) }

    private func loadFromDisk() {
        guard
            let data = try? Data(contentsOf: fileURL),
            let alarms = try? JSONDecoder().decode([AlarmData].self, from: data)
        else { return }
        cache = Dictionary(uniqueKeysWithValues: alarms.map { ($0.id, $0) })
    }

    private func saveToDisk() {
        guard let data = try? JSONEncoder().encode(Array(cache.values)) else { return }
        // .atomic writes to a tmp file then renames — same strategy as Android side
        try? data.write(to: fileURL, options: .atomic)
    }
}
