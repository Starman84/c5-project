import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var type: TransactionType
    var amount: Double
    var categoryName: String
    var note: String?
    var date: Date
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), type: TransactionType, amount: Double, categoryName: String, note: String? = nil, date: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.amount = amount
        self.categoryName = categoryName
        self.note = note
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
