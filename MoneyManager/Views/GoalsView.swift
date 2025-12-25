import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("selectedCurrency") private var selectedCurrency: String = CurrencyOption.sar.rawValue
    @Query private var goals: [SavingsGoal]
    @StateObject private var viewModel = GoalsViewModel()
    @State private var showAdd = false
    @State private var editingGoal: SavingsGoal?

    var body: some View {
        NavigationStack {
            List {
                ForEach(goals) { goal in
                    Button {
                        editingGoal = goal
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(goal.name)
                                    .bold()
                                Spacer()
                                Text("\(Int((goal.currentAmount / max(goal.targetAmount, 1)) * 100))٪")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: goal.currentAmount, total: goal.targetAmount)
                            HStack {
                                Text("المتاح")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: goal.currentAmount)) ?? "—")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { goals[$0] }.forEach { goal in
                        viewModel.deleteGoal(goal, context: context)
                    }
                }
            }
            .navigationTitle("الأهداف")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                GoalFormView(goal: nil) { name, target, context in
                    viewModel.addGoal(name: name, targetAmount: target, context: context)
                }
            }
            .sheet(item: $editingGoal) { goal in
                GoalFormView(goal: goal) { name, target, context in
                    goal.name = name
                    goal.targetAmount = target
                    try? context.save()
                }
            }
        }
    }
}

struct GoalFormView: View {
    let goal: SavingsGoal?
    let onSave: (String, Double, ModelContext) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var name: String = ""
    @State private var target: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("اسم الهدف")) {
                    TextField("مثال: سيارة", text: $name)
                }
                Section(header: Text("المبلغ المستهدف")) {
                    TextField("0", text: $target)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(goal == nil ? "هدف جديد" : "تعديل الهدف")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        guard let value = Double(target.replacingOccurrences(of: ",", with: ".")), !name.isEmpty else { return }
                        onSave(name, value, context)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
            }
            .onAppear {
                if let goal {
                    name = goal.name
                    target = String(goal.targetAmount)
                }
            }
        }
    }
}
