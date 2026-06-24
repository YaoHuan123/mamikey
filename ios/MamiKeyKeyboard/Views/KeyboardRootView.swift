import SwiftUI

struct KeyboardRootView: View {
  let onInsertText: (String) -> Void
  let onDeleteBackward: () -> Void
  let onAdvanceToNextInputMode: () -> Void
  let hasFullAccess: () -> Bool

  @State private var scene: CommunicationScene = .parentToTeacher
  @State private var childSubScene: ChildSubScene = .homework
  @State private var teacherSubScene: TeacherSubScene = .leave
  @State private var style: String = TeacherSubScene.leave.defaultStyle
  @State private var clipboardMessage = ""
  @State private var contextText = ""
  @State private var replies: [String] = []
  @State private var isLoading = false
  @State private var errorMessage: String?
  @State private var showContextField = false

  var body: some View {
    VStack(spacing: 8) {
      topBar
      sceneTabs
      subSceneChips
      stylePicker
      messagePreview
      actionRow
      if showContextField {
        contextField
      }
      if let errorMessage {
        Text(errorMessage)
          .font(.caption)
          .foregroundStyle(.red)
          .lineLimit(2)
      }
      repliesList
      bottomBar
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .background(Color(.systemGroupedBackground))
    .onAppear(perform: refreshClipboard)
  }

  private var topBar: some View {
    HStack {
      Text("Mami Key")
        .font(.caption.bold())
      Spacer()
      if !hasFullAccess() {
        Text("需开启完全访问")
          .font(.caption2)
          .foregroundStyle(.orange)
      }
      Text("余\(remainingLabel)")
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
  }

  private var remainingLabel: String {
    let remaining = QuotaManager.remainingToday
    if remaining == .max { return "∞" }
    return "\(remaining)"
  }

  private var sceneTabs: some View {
    Picker("场景", selection: $scene) {
      ForEach(CommunicationScene.allCases) { item in
        Text(item.title).tag(item)
      }
    }
    .pickerStyle(.segmented)
    .onChange(of: scene) { _ in
      syncStyleForScene()
    }
  }

  private var subSceneChips: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        if scene == .parentToChild {
          ForEach(ChildSubScene.allCases) { item in
            chip(title: item.rawValue, selected: childSubScene == item) {
              childSubScene = item
              style = item.defaultStyle
            }
          }
        } else {
          ForEach(TeacherSubScene.allCases) { item in
            chip(title: item.rawValue, selected: teacherSubScene == item) {
              teacherSubScene = item
              style = item.defaultStyle
            }
          }
        }
      }
    }
  }

  private func chip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(selected ? Color.accentColor : Color(.tertiarySystemFill))
        .foregroundStyle(selected ? Color.white : Color.primary)
        .clipShape(Capsule())
    }
    .buttonStyle(.plain)
  }

  private var stylePicker: some View {
    HStack {
      Text("风格")
        .font(.caption)
        .foregroundStyle(.secondary)
      Picker("风格", selection: $style) {
        ForEach(currentStyles, id: \.self) { item in
          Text(item).tag(item)
        }
      }
      .pickerStyle(.menu)
      Spacer()
      Button(showContextField ? "隐藏背景" : "+背景") {
        showContextField.toggle()
      }
      .font(.caption)
    }
  }

  private var currentStyles: [String] {
    switch scene {
    case .parentToChild:
      return childSubScene.availableStyles
    case .parentToTeacher:
      return teacherSubScene.availableStyles
    }
  }

  private var messagePreview: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text("对方消息")
          .font(.caption2)
          .foregroundStyle(.secondary)
        Spacer()
        Button("读取剪贴板") { refreshClipboard() }
          .font(.caption2)
      }
      Text(clipboardMessage.isEmpty ? "请先在微信复制对方消息" : clipboardMessage)
        .font(.caption)
        .lineLimit(2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }

  private var contextField: some View {
    TextField("补充背景，如：明天要交作业", text: $contextText)
      .font(.caption)
      .textFieldStyle(.roundedBorder)
  }

  private var actionRow: some View {
    Button {
      Task { await generateReplies() }
    } label: {
      HStack {
        if isLoading {
          ProgressView()
            .controlSize(.small)
        }
        Text(isLoading ? "生成中..." : "生成 3 条回复")
          .font(.subheadline.bold())
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 10)
      .background(Color.accentColor)
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .disabled(isLoading || clipboardMessage.isEmpty)
  }

  private var repliesList: some View {
    ScrollView {
      VStack(spacing: 6) {
        ForEach(Array(replies.enumerated()), id: \.offset) { index, reply in
          Button {
            onInsertText(reply)
            if let latest = HistoryStore.load().first {
              HistoryStore.markSelected(entryID: latest.id, reply: reply)
            }
          } label: {
            HStack(alignment: .top) {
              Text("\(index + 1).")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
              Text(reply)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
          }
          .buttonStyle(.plain)
        }
      }
    }
    .frame(maxHeight: 90)
  }

  private var bottomBar: some View {
    HStack {
      Button { onDeleteBackward() } label: {
        Image(systemName: "delete.left")
          .frame(width: 44, height: 36)
      }
      Spacer()
      Button { onAdvanceToNextInputMode() } label: {
        Image(systemName: "globe")
          .frame(width: 44, height: 36)
      }
    }
    .font(.title3)
  }

  private func syncStyleForScene() {
    switch scene {
    case .parentToChild:
      style = childSubScene.defaultStyle
    case .parentToTeacher:
      style = teacherSubScene.defaultStyle
    }
    replies = []
    errorMessage = nil
  }

  private func refreshClipboard() {
    if let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
      clipboardMessage = text
    }
  }

  @MainActor
  private func generateReplies() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    let request = GenerateRequest(
      scene: scene,
      childSubScene: scene == .parentToChild ? childSubScene : nil,
      teacherSubScene: scene == .parentToTeacher ? teacherSubScene : nil,
      style: style,
      message: clipboardMessage,
      context: contextText.isEmpty ? nil : contextText,
      childAge: SharedSettings.childAge.isEmpty ? nil : SharedSettings.childAge,
      grade: SharedSettings.grade.isEmpty ? nil : SharedSettings.grade,
      length: .short,
      mode: .generate,
      candidateCount: 3
    )

    do {
      replies = try await GenerateService.generate(request)
    } catch {
      errorMessage = error.localizedDescription
      replies = []
    }
  }
}
