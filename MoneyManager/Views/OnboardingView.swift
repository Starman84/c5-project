import SwiftUI

struct OnboardingScreen: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let image: String
}

struct OnboardingView: View {
    @Binding var didComplete: Bool
    @State private var currentIndex = 0

    private let screens = [
        OnboardingScreen(title: "مرحباً بك", description: "هذا التطبيق يساعدك على إدارة مصروفاتك ودخلك بسهولة وبخصوصية تامة.", image: "hand.wave"),
        OnboardingScreen(title: "أضف مصروفاتك بسرعة", description: "سجّل المبلغ والفئة والملاحظة متى ما صرفت شيئاً، وسترى ملخص اليوم فوراً.", image: "bolt"),
        OnboardingScreen(title: "راقب أسبوعك وشهرك", description: "شاهد ملخص الأسبوع والشهر مع رسوم واضحة تساعدك على اتخاذ قرارات أفضل.", image: "chart.bar"),
        OnboardingScreen(title: "حقق أهدافك", description: "أنشئ أهداف ادخار وتابع التقدم خطوة بخطوة مع تشجيع لطيف.", image: "target"),
        OnboardingScreen(title: "نسخ احتياطي بسهولة", description: "احفظ بياناتك محلياً وصدّر نسخة احتياطية متى شئت.", image: "tray.and.arrow.down")
    ]

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $currentIndex) {
                ForEach(Array(screens.enumerated()), id: \.offset) { index, screen in
                    VStack(spacing: 20) {
                        Image(systemName: screen.image)
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                            .accessibilityHidden(true)
                        Text(screen.title)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        Text(screen.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)

            Button(action: { didComplete = true }) {
                Text("ابدأ الآن")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .accessibilityLabel("ابدأ الآن")
        }
        .padding(.vertical)
    }
}
