import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      OnboardingView()
        .tabItem {
          Label("引导", systemImage: "keyboard")
        }

      SettingsView()
        .tabItem {
          Label("设置", systemImage: "gearshape")
        }

      HistoryView()
        .tabItem {
          Label("历史", systemImage: "clock")
        }
    }
  }
}

#Preview {
  ContentView()
}
