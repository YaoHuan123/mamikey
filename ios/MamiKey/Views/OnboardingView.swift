import SwiftUI

struct OnboardingView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          header
          steps
          usageTips
          quotaInfo
        }
        .padding()
      }
      .navigationTitle("Mami Key")
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("家长沟通 AI 键盘")
        .font(.title2.bold())
      Text("复制微信消息 → 切换到 Mami Key → 选场景生成 → 点击插入发送")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  private var steps: some View {
    VStack(alignment: .leading, spacing: 16) {
      stepRow(number: 1, title: "添加键盘", detail: "设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → Mami Key")
      stepRow(number: 2, title: "开启完全访问", detail: "点击 Mami Key → 打开「允许完全访问」（生成回复需要网络）")
      stepRow(number: 3, title: "配置 API（可选）", detail: "在「设置」页填入 API Key；不填则使用演示模式")
      stepRow(number: 4, title: "开始使用", detail: "微信里复制对方消息，切换到 Mami Key 键盘生成回复")
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private func stepRow(number: Int, title: String, detail: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Text("\(number)")
        .font(.caption.bold())
        .frame(width: 24, height: 24)
        .background(Color.accentColor.opacity(0.2))
        .clipShape(Circle())
      VStack(alignment: .leading, spacing: 4) {
        Text(title).font(.headline)
        Text(detail).font(.subheadline).foregroundStyle(.secondary)
      }
    }
  }

  private var usageTips: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("支持场景")
        .font(.headline)
      Label("对孩子：催作业、玩手机、顶嘴、表扬、谈心、道歉", systemImage: "figure.and.child.holdinghands")
      Label("对老师：请假、了解表现、反馈问题、感谢、道歉、约沟通", systemImage: "person.crop.circle.badge.checkmark")
    }
    .font(.subheadline)
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var quotaInfo: some View {
    HStack {
      Image(systemName: "gift")
      Text("每日免费 \(QuotaManager.dailyFreeLimit) 次生成")
      Spacer()
      Text("今日剩余 \(QuotaManager.remainingToday == .max ? "∞" : "\(QuotaManager.remainingToday)")")
        .foregroundStyle(.secondary)
    }
    .font(.subheadline)
    .padding()
    .background(Color(.tertiarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  OnboardingView()
}
