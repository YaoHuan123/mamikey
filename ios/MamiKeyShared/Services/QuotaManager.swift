import Foundation

enum QuotaManager {
  static let dailyFreeLimit = 5

  private static var defaults: UserDefaults? {
    UserDefaults(suiteName: SharedSettings.appGroupID)
  }

  static var remainingToday: Int {
    if SharedSettings.isSubscribed { return .max }
    resetIfNeeded()
    let used = defaults?.integer(forKey: SharedSettings.Key.dailyUsageCount) ?? 0
    return max(0, dailyFreeLimit - used)
  }

  static var canGenerate: Bool {
    SharedSettings.isSubscribed || remainingToday > 0
  }

  @discardableResult
  static func consumeOne() -> Bool {
    if SharedSettings.isSubscribed { return true }
    resetIfNeeded()
    guard remainingToday > 0 else { return false }
    let used = defaults?.integer(forKey: SharedSettings.Key.dailyUsageCount) ?? 0
    defaults?.set(used + 1, forKey: SharedSettings.Key.dailyUsageCount)
    return true
  }

  private static func resetIfNeeded() {
    let today = dayString(Date())
    let storedDay = defaults?.string(forKey: SharedSettings.Key.dailyUsageDate)
    if storedDay != today {
      defaults?.set(0, forKey: SharedSettings.Key.dailyUsageCount)
      defaults?.set(today, forKey: SharedSettings.Key.dailyUsageDate)
    }
  }

  private static func dayString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter.string(from: date)
  }
}
