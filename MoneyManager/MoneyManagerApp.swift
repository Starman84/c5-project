import SwiftUI
import SwiftData

@main
struct MoneyManagerApp: App {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
        }
        .modelContainer(for: [Transaction.self, Category.self, SavingsGoal.self, RecurringBill.self])
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        Group {
            if settingsViewModel.didCompleteOnboarding {
                MainTabView()
            } else {
                OnboardingView(didComplete: $settingsViewModel.didCompleteOnboarding)
            }
        }
        .onAppear {
            settingsViewModel.ensureDefaults(context: context)
            NotificationManager.shared.requestAuthorization()
        }
    }
}
