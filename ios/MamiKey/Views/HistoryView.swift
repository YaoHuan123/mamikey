import SwiftUI

struct HistoryView: View {
  @State private var entries: [HistoryEntry] = []

  var body: some View {
    NavigationStack {
      Group {
        if entries.isEmpty {
          VStack(spacing: 12) {
            Image(systemName: "clock")
              .font(.largeTitle)
              .foregroundStyle(.secondary)
            Text("暂无历史")
              .font(.headline)
            Text("在键盘中生成回复后会显示在这里")
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding()
        } else {
          List(entries) { entry in
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text(entry.scene.title)
                  .font(.caption.bold())
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.accentColor.opacity(0.15))
                  .clipShape(Capsule())
                Text(entry.subScene)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                Spacer()
                Text(entry.createdAt, style: .relative)
                  .font(.caption2)
                  .foregroundStyle(.secondary)
              }

              Text("对方：\(entry.inputMessage)")
                .font(.subheadline)
                .lineLimit(2)

              if let selected = entry.selectedReply {
                Text("已选：\(selected)")
                  .font(.subheadline)
                  .foregroundStyle(.primary)
              } else {
                Text(entry.replies.first ?? "")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
                  .lineLimit(2)
              }
            }
            .padding(.vertical, 4)
          }
        }
      }
      .navigationTitle("历史")
      .onAppear {
        entries = HistoryStore.load()
      }
    }
  }
}

#Preview {
  HistoryView()
}
