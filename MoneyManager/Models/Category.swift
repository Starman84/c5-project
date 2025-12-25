import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var monthlyLimit: Double
    var createdAt: Date

    init(id: UUID = UUID(), name: String, icon: String, colorHex: String, monthlyLimit: Double = 0, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.monthlyLimit = monthlyLimit
        self.createdAt = createdAt
    }
}
