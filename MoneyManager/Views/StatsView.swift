import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("selectedCurrency") private var selectedCurrency: String = CurrencyOption.sar.rawValue
    @Query private var transactions: [Transaction]
    @StateObject private var viewModel = StatsViewModel()
    @State private var selectedMonth = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthPicker
                    overviewCard
                    categoryPieCard
                    weeklyCard
                }
                .padding()
            }
            .navigationTitle("الإحصائيات")
        }
    }

    private var monthPicker: some View {
        DatePicker("الشهر", selection: $selectedMonth, displayedComponents: [.date])
            .datePickerStyle(.compact)
    }

    private var overviewCard: some View {
        let totals = viewModel.monthlyTotals(transactions: transactions, for: selectedMonth)
        let savings = totals.income - totals.expense
        return CardView(title: "ملخص الشهر") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("الدخل")
                    Spacer()
                    Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: totals.income)) ?? "—")
                }
                HStack {
                    Text("المصروف")
                    Spacer()
                    Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: totals.expense)) ?? "—")
                }
                HStack {
                    Text("الادخار")
                    Spacer()
                    Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: savings)) ?? "—")
                }
            }
        }
    }

    private var categoryPieCard: some View {
        let data = viewModel.categoryTotals(transactions: transactions, for: selectedMonth)
        return CardView(title: "توزيع المصروفات") {
            if data.isEmpty {
                Text("لا توجد بيانات لهذا الشهر.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(data) { item in
                    SectorMark(angle: .value("الإجمالي", item.total))
                        .foregroundStyle(by: .value("الفئة", item.name))
                        .annotation(position: .overlay) {
                            Text(item.name)
                                .font(.caption2)
                        }
                }
                .frame(height: 220)
            }
        }
    }

    private var weeklyCard: some View {
        let weeklyTotal = viewModel.weeklyTotal(transactions: transactions)
        return CardView(title: "ملخص الأسبوع") {
            Text("إجمالي مصروفات هذا الأسبوع: \(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: weeklyTotal)) ?? "—")")
                .foregroundStyle(.secondary)
        }
    }
}
