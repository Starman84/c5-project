import SwiftUI
import SwiftData

struct TransactionFormView: View {
    let type: TransactionType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage("selectedCurrency") private var selectedCurrency: String = CurrencyOption.sar.rawValue

    @State private var amount: String = ""
    @State private var selectedCategory: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()

    let transaction: Transaction?
    let categories: [Category]
    let onSave: (TransactionType, Double, String, String?, Date, ModelContext) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("المبلغ")) {
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityLabel("المبلغ")
                }
                Section(header: Text("الفئة")) {
                    Picker("الفئة", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    .accessibilityLabel("اختيار الفئة")
                }
                Section(header: Text("ملاحظة")) {
                    TextField("اختياري", text: $note)
                        .accessibilityLabel("ملاحظة")
                }
                Section(header: Text("التاريخ")) {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "ar"))
                }
            }
            .navigationTitle(type == .expense ? "مصروف جديد" : "دخل جديد")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")), !selectedCategory.isEmpty else { return }
                        onSave(type, value, selectedCategory, note.isEmpty ? nil : note, date, context)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
            }
            .onAppear {
                if let transaction {
                    amount = String(transaction.amount)
                    selectedCategory = transaction.categoryName
                    note = transaction.note ?? ""
                    date = transaction.date
                } else {
                    selectedCategory = categories.first?.name ?? ""
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
    }
}
