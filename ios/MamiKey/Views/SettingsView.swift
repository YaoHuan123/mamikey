import SwiftUI

struct SettingsView: View {
  @State private var apiBaseURL = SharedSettings.apiBaseURL
  @State private var apiKey = SharedSettings.apiKey
  @State private var modelName = SharedSettings.modelName
  @State private var useMockMode = SharedSettings.useMockMode
  @State private var childAge = SharedSettings.childAge
  @State private var grade = SharedSettings.grade
  @State private var isSubscribed = SharedSettings.isSubscribed
  @State private var savedMessage: String?

  var body: some View {
    NavigationStack {
      Form {
        Section("孩子信息（默认填入键盘）") {
          TextField("孩子年龄/年级，如：小学四年级", text: $childAge)
          TextField("班级，如：三年级2班", text: $grade)
        }

        Section("AI 接口（OpenAI 兼容）") {
          TextField("Base URL", text: $apiBaseURL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          SecureField("API Key", text: $apiKey)
          TextField("Model", text: $modelName)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          Toggle("演示模式（Mock，不调用 API）", isOn: $useMockMode)
        }

        Section("订阅（开发调试）") {
          Toggle("模拟已订阅（无限次）", isOn: $isSubscribed)
          Text("正式版将接入 StoreKit")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Section {
          Button("保存设置") {
            save()
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }

        if let savedMessage {
          Section {
            Text(savedMessage)
              .foregroundStyle(.green)
          }
        }

        Section("推荐配置") {
          VStack(alignment: .leading, spacing: 6) {
            Text("DeepSeek: https://api.deepseek.com")
            Text("Model: deepseek-chat")
            Text("或任何 OpenAI 兼容端点")
          }
          .font(.caption)
          .foregroundStyle(.secondary)
        }
      }
      .navigationTitle("设置")
      .onAppear(perform: reload)
    }
  }

  private func reload() {
    apiBaseURL = SharedSettings.apiBaseURL
    apiKey = SharedSettings.apiKey
    modelName = SharedSettings.modelName
    useMockMode = SharedSettings.useMockMode
    childAge = SharedSettings.childAge
    grade = SharedSettings.grade
    isSubscribed = SharedSettings.isSubscribed
  }

  private func save() {
    SharedSettings.apiBaseURL = apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    SharedSettings.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    SharedSettings.modelName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
    SharedSettings.useMockMode = useMockMode
    SharedSettings.childAge = childAge.trimmingCharacters(in: .whitespacesAndNewlines)
    SharedSettings.grade = grade.trimmingCharacters(in: .whitespacesAndNewlines)
    SharedSettings.isSubscribed = isSubscribed
    savedMessage = "已保存"
  }
}

#Preview {
  SettingsView()
}
