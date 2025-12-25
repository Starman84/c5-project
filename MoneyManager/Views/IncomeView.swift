import SwiftUI
import SwiftData

struct IncomeView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("selectedCurrency") private var selectedCurrency: String = CurrencyOption.sar.rawValue
    @Query private var transactions: [Transaction]
    @Query private var categories: [Category]
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var showAdd = false
    @State private var editingTransaction: Transaction?

    private var incomeTransactions: [Transaction] {
        transactions.filter { $0.type == .income }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(incomeTransactions.sorted { $0.date > $1.date }) { transaction in
                    Button {
                        editingTransaction = transaction
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(transaction.note ?? "دخل")
                                    .bold()
                                Text(Formatters.shortDate.string(from: transaction.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Formatters.currencyFormatter(currencyCode: selectedCurrency).string(from: NSNumber(value: transaction.amount)) ?? "—")
                                .bold()
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { incomeTransactions.sorted { $0.date > $1.date }[$0] }.forEach { transaction in
                        viewModel.deleteTransaction(transaction, context: context)
                    }
                }
            }
            .navigationTitle("الدخل")
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
                TransactionFormView(type: .income, transaction: nil, categories: incomeCategories, onSave: viewModel.addTransaction)
            }
            .sheet(item: $editingTransaction) { transaction in
                TransactionFormView(type: .income, transaction: transaction, categories: incomeCategories, onSave: { _, amount, category, note, date, context in
                    viewModel.updateTransaction(transaction, amount: amount, categoryName: category, note: note, date: date, context: context)
                })
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    if viewModel.showUndo {
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
                    if viewModel.showEditUndo {
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
            }
        }
    }

    private var incomeCategories: [Category] {
        let incomeCategory = Category(name: "الدخل", icon: "tray.and.arrow.down", colorHex: "#4CAF50")
        return [incomeCategory] + categories
    }
}
