import Foundation
import SwiftData
import SwiftUI

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var lastDeleted: Transaction?
    @Published var lastEditedSnapshot: TransactionSnapshot?
    @Published var showUndo: Bool = false
    @Published var showEditUndo: Bool = false
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "الكل"
    @Published var selectedDate: Date? = nil

    func addTransaction(type: TransactionType, amount: Double, categoryName: String, note: String?, date: Date, context: ModelContext) {
        let transaction = Transaction(type: type, amount: amount, categoryName: categoryName, note: note, date: date)
        context.insert(transaction)
        try? context.save()
        if type == .expense {
            checkCategoryLimit(categoryName: categoryName, context: context)
        }
    }

    func updateTransaction(_ transaction: Transaction, amount: Double, categoryName: String, note: String?, date: Date, context: ModelContext) {
        lastEditedSnapshot = TransactionSnapshot(id: transaction.id, amount: transaction.amount, categoryName: transaction.categoryName, note: transaction.note, date: transaction.date)
        transaction.amount = amount
        transaction.categoryName = categoryName
        transaction.note = note
        transaction.date = date
        transaction.updatedAt = Date()
        try? context.save()
        if transaction.type == .expense {
            checkCategoryLimit(categoryName: categoryName, context: context)
        }
        showEditUndo = true
    }

    func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        lastDeleted = transaction
        context.delete(transaction)
        try? context.save()
        showUndo = true
    }

    func undoDelete(context: ModelContext) {
        guard let transaction = lastDeleted else { return }
        context.insert(transaction)
        try? context.save()
        showUndo = false
        lastDeleted = nil
    }

    func undoEdit(context: ModelContext) {
        guard let snapshot = lastEditedSnapshot else { return }
        let transactions = (try? context.fetch(FetchDescriptor<Transaction>())) ?? []
        if let transaction = transactions.first(where: { $0.id == snapshot.id }) {
            transaction.amount = snapshot.amount
            transaction.categoryName = snapshot.categoryName
            transaction.note = snapshot.note
            transaction.date = snapshot.date
            transaction.updatedAt = Date()
            try? context.save()
        }
        showEditUndo = false
        lastEditedSnapshot = nil
    }

    func filteredTransactions(_ transactions: [Transaction]) -> [Transaction] {
        transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty || transaction.note?.localizedCaseInsensitiveContains(searchText) == true || transaction.categoryName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "الكل" || transaction.categoryName == selectedCategory
            let matchesDate: Bool
            if let selectedDate {
                matchesDate = Calendar.current.isDate(transaction.date, inSameDayAs: selectedDate)
            } else {
                matchesDate = true
            }
            return matchesSearch && matchesCategory && matchesDate
        }.sorted { $0.date > $1.date }
    }

    private func checkCategoryLimit(categoryName: String, context: ModelContext) {
        let categories = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        guard let category = categories.first(where: { $0.name == categoryName }) else { return }
        guard category.monthlyLimit > 0 else { return }

        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
        let transactions = (try? context.fetch(FetchDescriptor<Transaction>())) ?? []
        let total = transactions.filter { $0.type == .expense && $0.categoryName == categoryName && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
        let ratio = total / category.monthlyLimit
        if ratio >= 0.8 && ratio < 1.05 {
            NotificationManager.shared.scheduleLimitAlert(categoryName: categoryName, remainingPercentage: max(0, 1 - ratio))
        }
    }
}

struct TransactionSnapshot {
    let id: UUID
    let amount: Double
    let categoryName: String
    let note: String?
    let date: Date
}
