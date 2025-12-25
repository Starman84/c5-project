import Foundation
import SwiftData

struct CategoryTotal: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
}

@MainActor
final class StatsViewModel: ObservableObject {
    func monthlyTotals(transactions: [Transaction], for month: Date) -> (income: Double, expense: Double) {
        let range = monthRange(month)
        let monthTransactions = transactions.filter { $0.date >= range.start && $0.date <= range.end }
        let income = monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return (income, expense)
    }

    func weeklyTotal(transactions: [Transaction]) -> Double {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return transactions.filter { $0.type == .expense && $0.date >= startOfWeek }.reduce(0) { $0 + $1.amount }
    }

    func dailyTotal(transactions: [Transaction]) -> Double {
        let today = Date()
        return transactions.filter { $0.type == .expense && Calendar.current.isDate($0.date, inSameDayAs: today) }.reduce(0) { $0 + $1.amount }
    }

    func categoryTotals(transactions: [Transaction], for month: Date) -> [CategoryTotal] {
        let range = monthRange(month)
        let filtered = transactions.filter { $0.type == .expense && $0.date >= range.start && $0.date <= range.end }
        let grouped = Dictionary(grouping: filtered, by: { $0.categoryName })
        return grouped.map { CategoryTotal(name: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    private func monthRange(_ date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? date
        return (start, end)
    }
}
