import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("الرئيسية", systemImage: "house") }
            ExpensesView()
                .tabItem { Label("المصروفات", systemImage: "creditcard") }
            IncomeView()
                .tabItem { Label("الدخل", systemImage: "tray.and.arrow.down") }
            GoalsView()
                .tabItem { Label("الأهداف", systemImage: "target") }
            StatsView()
                .tabItem { Label("الإحصائيات", systemImage: "chart.pie") }
            SettingsView()
                .tabItem { Label("الإعدادات", systemImage: "gear") }
        }
    }
}
