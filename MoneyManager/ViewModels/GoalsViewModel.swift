import Foundation
import SwiftData

@MainActor
final class GoalsViewModel: ObservableObject {
    func addGoal(name: String, targetAmount: Double, context: ModelContext) {
        let goal = SavingsGoal(name: name, targetAmount: targetAmount)
        context.insert(goal)
        try? context.save()
    }

    func updateProgress(goal: SavingsGoal, amount: Double, context: ModelContext) {
        goal.currentAmount = amount
        try? context.save()
    }

    func deleteGoal(_ goal: SavingsGoal, context: ModelContext) {
        context.delete(goal)
        try? context.save()
    }
}
