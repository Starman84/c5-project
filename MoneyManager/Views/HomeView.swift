import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("selectedCurrency") private var selectedCurrency: String = CurrencyOption.sar.rawValue
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    @Query private var goals: [SavingsGoal]
    @StateObject private var statsViewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    todayCard
                    goalsCard
                    motivationCard
                }
                .padding()
            }
            .navigationTitle("الرئيسية")
        }
    }

    private var summaryCard: some View {
        let monthly = statsViewModel.monthlyTotals(transactions: transactions, for: Date())
        let balance = monthly.income - monthly.expense
        return CardView(title: "رصيد هذا الشهر") {
            Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: balance)) ?? "—")
                .font(.title2)
                .bold()
                .accessibilityLabel("رصيد هذا الشهر")
        }
    }

    private var todayCard: some View {
        CardView(title: "مصروفات اليوم") {
            let total = statsViewModel.dailyTotal(transactions: transactions)
            Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: total)) ?? "—")
                .font(.title2)
                .bold()
                .accessibilityLabel("مصروفات اليوم")
        }
    }

    private var goalsCard: some View {
        CardView(title: "أهداف الادخار") {
            if goals.isEmpty {
                Text("ابدأ هدفاً جديداً لتتبع تقدمك.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(goals.prefix(3)) { goal in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.name)
                                    .bold()
                                Text("\(Int((goal.currentAmount / max(goal.targetAmount, 1)) * 100))٪ مكتمل")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: goal.currentAmount)) ?? "—")
                        }
                    }
                }
            }
        }
    }

    private var motivationCard: some View {
        CardView(title: "رسالة اليوم") {
            Text("استمر بالخطوات الصغيرة، النتائج الكبيرة في الطريق.")
                .foregroundStyle(.secondary)
        }
    }
}

struct CardView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
