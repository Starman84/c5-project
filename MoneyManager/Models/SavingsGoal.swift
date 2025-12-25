import Foundation
import SwiftData

@Model
final class SavingsGoal {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var createdAt: Date

    init(id: UUID = UUID(), name: String, targetAmount: Double, currentAmount: Double = 0, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.createdAt = createdAt
    }
}
