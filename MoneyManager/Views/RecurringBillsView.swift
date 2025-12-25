import SwiftUI
import SwiftData

struct RecurringBillsView: View {
    @Environment(\.modelContext) private var context
    @Query private var bills: [RecurringBill]
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(bills) { bill in
                HStack {
                    VStack(alignment: .leading) {
                        Text(bill.name)
                            .bold()
                        Text("يوم \(bill.dueDay) من كل شهر")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { bill.isActive },
                        set: { newValue in
                            bill.isActive = newValue
                            try? context.save()
                            if newValue {
                                NotificationManager.shared.scheduleRecurringBillReminder(bill: bill)
                            } else {
                                NotificationManager.shared.cancelRecurringBillReminder(bill: bill)
                            }
                        }
                    ))
                    .labelsHidden()
                }
            }
            .onDelete { indexSet in
                indexSet.map { bills[$0] }.forEach { bill in
                    NotificationManager.shared.cancelRecurringBillReminder(bill: bill)
                    context.delete(bill)
                    try? context.save()
                }
            }
        }
        .navigationTitle("تذكير الفواتير")
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
            RecurringBillFormView { name, amount, dueDay, context in
                let bill = RecurringBill(name: name, amount: amount, dueDay: dueDay)
                context.insert(bill)
                try? context.save()
                NotificationManager.shared.scheduleRecurringBillReminder(bill: bill)
            }
        }
    }
}

struct RecurringBillFormView: View {
    let onSave: (String, Double, Int, ModelContext) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var dueDay: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("اسم الفاتورة")) {
                    TextField("مثال: إنترنت", text: $name)
                }
                Section(header: Text("المبلغ")) {
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("اليوم الشهري")) {
                    Stepper("اليوم: \(dueDay)", value: $dueDay, in: 1...28)
                }
            }
            .navigationTitle("فاتورة جديدة")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")), !name.isEmpty else { return }
                        onSave(name, value, dueDay, context)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
            }
        }
    }
}
