import Foundation

enum HistoryStore {
  private static let maxCount = 20

  private static var defaults: UserDefaults? {
    UserDefaults(suiteName: SharedSettings.appGroupID)
  }

  static func load() -> [HistoryEntry] {
    guard
      let data = defaults?.data(forKey: SharedSettings.Key.historyJSON),
      let entries = try? JSONDecoder().decode([HistoryEntry].self, from: data)
    else {
      return []
    }
    return entries
  }

  static func append(_ entry: HistoryEntry) {
    var entries = load()
    entries.insert(entry, at: 0)
    if entries.count > maxCount {
      entries = Array(entries.prefix(maxCount))
    }
    save(entries)
  }

  static func markSelected(entryID: UUID, reply: String) {
    var entries = load()
    guard let index = entries.firstIndex(where: { $0.id == entryID }) else { return }
    let old = entries[index]
    entries[index] = HistoryEntry(
      id: old.id,
      createdAt: old.createdAt,
      scene: old.scene,
      subScene: old.subScene,
      inputMessage: old.inputMessage,
      replies: old.replies,
      selectedReply: reply
    )
    save(entries)
  }

  private static func save(_ entries: [HistoryEntry]) {
    guard let data = try? JSONEncoder().encode(entries) else { return }
    defaults?.set(data, forKey: SharedSettings.Key.historyJSON)
  }
}
