import Foundation
import SwiftData

@Model
final class RecurringBill {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var dueDay: Int
    var isActive: Bool
    var createdAt: Date

    init(id: UUID = UUID(), name: String, amount: Double, dueDay: Int, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.dueDay = dueDay
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
