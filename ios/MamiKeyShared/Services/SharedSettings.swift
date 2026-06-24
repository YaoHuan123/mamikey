import Foundation

enum SharedSettings {
  static let appGroupID = "group.io.github.YaoHuan123.mamikey"

  private static var defaults: UserDefaults? {
    UserDefaults(suiteName: appGroupID)
  }

  enum Key {
    static let apiBaseURL = "apiBaseURL"
    static let apiKey = "apiKey"
    static let modelName = "modelName"
    static let useMockMode = "useMockMode"
    static let childAge = "childAge"
    static let grade = "grade"
    static let dailyUsageCount = "dailyUsageCount"
    static let dailyUsageDate = "dailyUsageDate"
    static let historyJSON = "historyJSON"
    static let isSubscribed = "isSubscribed"
  }

  static var apiBaseURL: String {
    get { defaults?.string(forKey: Key.apiBaseURL) ?? "https://api.deepseek.com" }
    set { defaults?.set(newValue, forKey: Key.apiBaseURL) }
  }

  static var apiKey: String {
    get { defaults?.string(forKey: Key.apiKey) ?? "" }
    set { defaults?.set(newValue, forKey: Key.apiKey) }
  }

  static var modelName: String {
    get { defaults?.string(forKey: Key.modelName) ?? "deepseek-chat" }
    set { defaults?.set(newValue, forKey: Key.modelName) }
  }

  static var useMockMode: Bool {
    get {
      if defaults?.object(forKey: Key.useMockMode) == nil {
        return apiKey.isEmpty
      }
      return defaults?.bool(forKey: Key.useMockMode) ?? true
    }
    set { defaults?.set(newValue, forKey: Key.useMockMode) }
  }

  static var childAge: String {
    get { defaults?.string(forKey: Key.childAge) ?? "" }
    set { defaults?.set(newValue, forKey: Key.childAge) }
  }

  static var grade: String {
    get { defaults?.string(forKey: Key.grade) ?? "" }
    set { defaults?.set(newValue, forKey: Key.grade) }
  }

  static var isSubscribed: Bool {
    get { defaults?.bool(forKey: Key.isSubscribed) ?? false }
    set { defaults?.set(newValue, forKey: Key.isSubscribed) }
  }
}
