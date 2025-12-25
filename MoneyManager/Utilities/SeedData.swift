import Foundation
import SwiftData

enum SeedData {
    static func addDefaultCategories(to context: ModelContext) {
        let defaults: [(String, String, String)] = [
            ("الطعام", "fork.knife", "#FF8A65"),
            ("المواصلات", "car", "#4DB6AC"),
            ("المنزل", "house", "#9575CD"),
            ("التسوق", "bag", "#F06292"),
            ("الصحة", "heart", "#4FC3F7"),
            ("الترفيه", "gamecontroller", "#BA68C8")
        ]

        defaults.forEach { name, icon, color in
            context.insert(Category(name: name, icon: icon, colorHex: color))
        }
    }

    static func addSampleData(to context: ModelContext) {
        let categories = [
            Category(name: "الطعام", icon: "fork.knife", colorHex: "#FF8A65", monthlyLimit: 300),
            Category(name: "المواصلات", icon: "car", colorHex: "#4DB6AC", monthlyLimit: 200),
            Category(name: "المنزل", icon: "house", colorHex: "#9575CD", monthlyLimit: 500)
        ]
        categories.forEach { context.insert($0) }

        let transactions = [
            Transaction(type: .expense, amount: 45, categoryName: "الطعام", note: "قهوة وفطور", date: Date()),
            Transaction(type: .expense, amount: 60, categoryName: "المواصلات", note: "بنزين", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
            Transaction(type: .income, amount: 1200, categoryName: "الدخل", note: "راتب", date: Date())
        ]
        transactions.forEach { context.insert($0) }

        let goals = [
            SavingsGoal(name: "رحلة عائلية", targetAmount: 2000, currentAmount: 550)
        ]
        goals.forEach { context.insert($0) }

        let bills = [
            RecurringBill(name: "اشتراك هاتف", amount: 80, dueDay: 5, isActive: true)
        ]
        bills.forEach { context.insert($0) }
    }
}
