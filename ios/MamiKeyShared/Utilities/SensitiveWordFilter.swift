import Foundation

enum SensitiveWordFilter {
  private static let blockedPhrases = [
    "白养你了",
    "不管你了",
    "滚",
    "废物",
    "蠢",
    "去死",
    "投诉你",
    "告校长",
    "教育局",
    "保证考第一",
    "保证下次",
  ]

  static func isSafe(_ text: String) -> Bool {
    let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else { return false }
    return !blockedPhrases.contains { normalized.contains($0) }
  }

  static func filter(_ replies: [String]) -> [String] {
    replies.filter(isSafe)
  }
}
