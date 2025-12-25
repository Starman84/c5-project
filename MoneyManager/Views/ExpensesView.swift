import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("selectedCurrency") private var selectedCurrency: String = CurrencyOption.sar.rawValue
    @Query private var transactions: [Transaction]
    @Query private var categories: [Category]
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var showAdd = false
    @State private var editingTransaction: Transaction?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                filters
                List {
                    ForEach(viewModel.filteredTransactions(expenseTransactions)) { transaction in
                        Button {
                            editingTransaction = transaction
                        } label: {
                            transactionRow(transaction)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { viewModel.filteredTransactions(expenseTransactions)[$0] }.forEach { transaction in
                            viewModel.deleteTransaction(transaction, context: context)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("المصروفات")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("إضافة مصروف")
                }
            }
            .sheet(isPresented: $showAdd) {
                TransactionFormView(type: .expense, transaction: nil, categories: categories, onSave: viewModel.addTransaction)
            }
            .sheet(item: $editingTransaction) { transaction in
                TransactionFormView(type: .expense, transaction: transaction, categories: categories, onSave: { _, amount, category, note, date, context in
                    viewModel.updateTransaction(transaction, amount: amount, categoryName: category, note: note, date: date, context: context)
                })
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    if viewModel.showUndo {
                        undoBanner
                    }
                    if viewModel.showEditUndo {
                        editUndoBanner
                    }
                }
            }
        }
    }

    private var expenseTransactions: [Transaction] {
        transactions.filter { $0.type == .expense }
    }

    private var filters: some View {
        VStack(spacing: 8) {
            TextField("ابحث بكلمة أو ملاحظة", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .accessibilityLabel("بحث")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: { viewModel.selectedCategory = "الكل" }) {
                        Text("الكل")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(viewModel.selectedCategory == "الكل" ? Color.blue : Color(.secondarySystemBackground))
                            .foregroundColor(viewModel.selectedCategory == "الكل" ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    ForEach(categories) { category in
                        Button(action: { viewModel.selectedCategory = category.name }) {
                            Text(category.name)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(viewModel.selectedCategory == category.name ? Color.blue : Color(.secondarySystemBackground))
                                .foregroundColor(viewModel.selectedCategory == category.name ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                Toggle("تصفية حسب اليوم", isOn: Binding(
                    get: { viewModel.selectedDate != nil },
                    set: { isOn in
                        viewModel.selectedDate = isOn ? Date() : nil
                    }
                ))
                .toggleStyle(.switch)
                Spacer()
            }
            .padding(.horizontal)

            if viewModel.selectedDate != nil {
                DatePicker("اليوم", selection: Binding($viewModel.selectedDate, replacingNilWith: Date()), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
            }
        }
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.categoryName)
                    .bold()
                if let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: transaction.amount)) ?? "—")
                    .bold()
                Text(Formatters.shortDate.string(from: transaction.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var undoBanner: some View {
        HStack {
            Text("تم الحذف")
            Spacer()
            Button("تراجع") {
                viewModel.undoDelete(context: context)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 3)
        .padding()
    }

    private var editUndoBanner: some View {
        HStack {
            Text("تم التعديل")
            Spacer()
            Button("تراجع") {
                viewModel.undoEdit(context: context)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 3)
        .padding()
    }
}

extension Binding where Value == Date? {
    init(_ source: Binding<Date?>, replacingNilWith replacement: Date) {
        self.init(get: { source.wrappedValue ?? replacement }, set: { newValue in source.wrappedValue = newValue })
    }
}
