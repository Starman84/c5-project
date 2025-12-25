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
        let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate<Transaction> { transaction in
            transaction.id == snapshot.id
        })
        if let transaction = try? context.fetch(descriptor).first {
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
        guard let category = try? context.fetch(FetchDescriptor<Category>(predicate: #Predicate<Category> { category in
            category.name == categoryName
        })).first else { return }
        guard category.monthlyLimit > 0 else { return }

        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
        let descriptor = FetchDescriptor<Transaction>(predicate: #Predicate<Transaction> { transaction in
            transaction.type == TransactionType.expense &&
            transaction.categoryName == categoryName &&
            transaction.date >= startOfMonth
        })
        let total = (try? context.fetch(descriptor).reduce(0) { $0 + $1.amount }) ?? 0
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
