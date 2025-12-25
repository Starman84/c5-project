import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showAdd = false
    @State private var editingCategory: Category?

    var body: some View {
        List {
            ForEach(categories) { category in
                Button {
                    editingCategory = category
                } label: {
                    HStack {
                        Image(systemName: category.icon)
                        Text(category.name)
                        Spacer()
                        if category.monthlyLimit > 0 {
                            Text("حد: \(Int(category.monthlyLimit))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.map { categories[$0] }.forEach { category in
                    viewModel.deleteCategory(category, context: context)
                }
            }
        }
        .navigationTitle("إدارة الفئات")
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
            CategoryFormView(category: nil) { name, icon, color, limit, context in
                viewModel.addCategory(name: name, icon: icon, colorHex: color, limit: limit, context: context)
            }
        }
        .sheet(item: $editingCategory) { category in
            CategoryFormView(category: category) { name, icon, color, limit, context in
                category.name = name
                category.icon = icon
                category.colorHex = color
                category.monthlyLimit = limit
                try? context.save()
            }
        }
    }
}

struct CategoryFormView: View {
    let category: Category?
    let onSave: (String, String, String, Double, ModelContext) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var name: String = ""
    @State private var icon: String = "tag"
    @State private var colorHex: String = "#4FC3F7"
    @State private var limit: String = ""

    private let icons = ["fork.knife", "car", "house", "bag", "heart", "gamecontroller", "book", "gift"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("الاسم")) {
                    TextField("اسم الفئة", text: $name)
                }
                Section(header: Text("الأيقونة")) {
                    Picker("الأيقونة", selection: $icon) {
                        ForEach(icons, id: \.self) { icon in
                            Label(icon, systemImage: icon).tag(icon)
                        }
                    }
                }
                Section(header: Text("لون")) {
                    TextField("مثال: #4FC3F7", text: $colorHex)
                }
                Section(header: Text("حد شهري (اختياري)")) {
                    TextField("0", text: $limit)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(category == nil ? "فئة جديدة" : "تعديل فئة")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        guard !name.isEmpty else { return }
                        let value = Double(limit.replacingOccurrences(of: ",", with: ".")) ?? 0
                        onSave(name, icon, colorHex, value, context)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
            }
            .onAppear {
                if let category {
                    name = category.name
                    icon = category.icon
                    colorHex = category.colorHex
                    limit = category.monthlyLimit > 0 ? String(category.monthlyLimit) : ""
                }
            }
        }
    }
}
