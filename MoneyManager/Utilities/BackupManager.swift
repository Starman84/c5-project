import Foundation
import SwiftData

struct BackupPackage: Codable {
    var transactions: [TransactionDTO]
    var categories: [CategoryDTO]
    var goals: [SavingsGoalDTO]
    var bills: [RecurringBillDTO]
}

struct TransactionDTO: Codable {
    var id: UUID
    var type: TransactionType
    var amount: Double
    var categoryName: String
    var note: String?
    var date: Date
    var createdAt: Date
    var updatedAt: Date
}

struct CategoryDTO: Codable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var monthlyLimit: Double
    var createdAt: Date
}

struct SavingsGoalDTO: Codable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var createdAt: Date
}

struct RecurringBillDTO: Codable {
    var id: UUID
    var name: String
    var amount: Double
    var dueDay: Int
    var isActive: Bool
    var createdAt: Date
}

final class BackupManager {
    func exportData(from context: ModelContext) throws -> Data {
        let transactions = try context.fetch(FetchDescriptor<Transaction>())
        let categories = try context.fetch(FetchDescriptor<Category>())
        let goals = try context.fetch(FetchDescriptor<SavingsGoal>())
        let bills = try context.fetch(FetchDescriptor<RecurringBill>())

        let package = BackupPackage(
            transactions: transactions.map { TransactionDTO(id: $0.id, type: $0.type, amount: $0.amount, categoryName: $0.categoryName, note: $0.note, date: $0.date, createdAt: $0.createdAt, updatedAt: $0.updatedAt) },
            categories: categories.map { CategoryDTO(id: $0.id, name: $0.name, icon: $0.icon, colorHex: $0.colorHex, monthlyLimit: $0.monthlyLimit, createdAt: $0.createdAt) },
            goals: goals.map { SavingsGoalDTO(id: $0.id, name: $0.name, targetAmount: $0.targetAmount, currentAmount: $0.currentAmount, createdAt: $0.createdAt) },
            bills: bills.map { RecurringBillDTO(id: $0.id, name: $0.name, amount: $0.amount, dueDay: $0.dueDay, isActive: $0.isActive, createdAt: $0.createdAt) }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(package)
    }

    func importData(_ data: Data, into context: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let package = try decoder.decode(BackupPackage.self, from: data)

        package.categories.forEach { dto in
            context.insert(Category(id: dto.id, name: dto.name, icon: dto.icon, colorHex: dto.colorHex, monthlyLimit: dto.monthlyLimit, createdAt: dto.createdAt))
        }
        package.transactions.forEach { dto in
            context.insert(Transaction(id: dto.id, type: dto.type, amount: dto.amount, categoryName: dto.categoryName, note: dto.note, date: dto.date, createdAt: dto.createdAt, updatedAt: dto.updatedAt))
        }
        package.goals.forEach { dto in
            context.insert(SavingsGoal(id: dto.id, name: dto.name, targetAmount: dto.targetAmount, currentAmount: dto.currentAmount, createdAt: dto.createdAt))
        }
        package.bills.forEach { dto in
            context.insert(RecurringBill(id: dto.id, name: dto.name, amount: dto.amount, dueDay: dto.dueDay, isActive: dto.isActive, createdAt: dto.createdAt))
        }

        try context.save()
    }
}
