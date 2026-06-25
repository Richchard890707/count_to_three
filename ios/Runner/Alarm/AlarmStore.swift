import Foundation

final class AlarmStore {
    static let shared = AlarmStore()
    private var cache: [Int: AlarmData] = [:]
    private let queue = DispatchQueue(
        label: "com.example.count_to_three.AlarmStore",
        attributes: .concurrent
    )
    private let fileURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("alarm_store.json")
    }()

    private init() { loadFromDisk() }

    func put(_ alarm: AlarmData) {
        queue.async(flags: .barrier) {
            self.cache[alarm.id] = alarm
            self.saveToDisk()
        }
    }

    func get(_ id: Int) -> AlarmData? {
        queue.sync { cache[id] }
    }

    func remove(_ id: Int) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: id)
            self.saveToDisk()
        }
    }

    func getAll() -> [AlarmData] {
        queue.sync { Array(cache.values) }
    }

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
