import Foundation
import SwiftData
import SwiftUI

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    func addCategory(name: String, icon: String, colorHex: String, limit: Double, context: ModelContext) {
        let category = Category(name: name, icon: icon, colorHex: colorHex, monthlyLimit: limit)
        context.insert(category)
        try? context.save()
    }

    func renameCategory(_ category: Category, newName: String, context: ModelContext) {
        category.name = newName
        try? context.save()
    }

    func updateLimit(_ category: Category, limit: Double, context: ModelContext) {
        category.monthlyLimit = limit
        try? context.save()
    }

    func deleteCategory(_ category: Category, context: ModelContext) {
        context.delete(category)
        try? context.save()
    }
}
