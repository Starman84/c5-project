import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showExporter = false
    @State private var showImporter = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("العملة")) {
                    Picker("اختر العملة", selection: $viewModel.selectedCurrency) {
                        ForEach(CurrencyOption.allCases) { currency in
                            Text("\(currency.localizedName) - \(currency.symbol)")
                                .tag(currency.rawValue)
                        }
                    }
                    .accessibilityLabel("اختيار العملة")
                }

                Section(header: Text("النسخ الاحتياطي")) {
                    Button("تصدير نسخة احتياطية") {
                        viewModel.exportBackup(context: context)
                        if viewModel.exportData != nil {
                            showExporter = true
                        }
                    }
                    Button("استيراد نسخة احتياطية") {
                        showImporter = true
                    }
                }

                Section(header: Text("البيانات التجريبية")) {
                    Toggle("إضافة بيانات توضيحية", isOn: $viewModel.useSampleData)
                        .onChange(of: viewModel.useSampleData) { _, _ in
                            viewModel.applySampleData(context: context)
                        }
                }

                Section(header: Text("إدارة")) {
                    NavigationLink("إدارة الفئات") {
                        CategoriesView()
                    }
                    NavigationLink("تذكير الفواتير") {
                        RecurringBillsView()
                    }
                }

                Section(header: Text("مساعدة")) {
                    Text("بياناتك محفوظة محلياً فقط ولا يتم إرسالها لأي جهة.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("الإعدادات")
            .fileExporter(isPresented: $showExporter, document: BackupDocument(data: viewModel.exportData ?? Data()), contentType: .json, defaultFilename: "money-backup.json") { _ in }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    if let data = try? Data(contentsOf: url) {
                        viewModel.importBackup(data: data, context: context)
                    } else {
                        viewModel.message = "تعذر قراءة الملف."
                        viewModel.showImportError = true
                    }
                case .failure:
                    viewModel.message = "تعذر استيراد الملف."
                    viewModel.showImportError = true
                }
            }
            .alert(viewModel.message, isPresented: $viewModel.showExportError) {
                Button("حسناً", role: .cancel) { }
            }
            .alert(viewModel.message, isPresented: $viewModel.showImportError) {
                Button("حسناً", role: .cancel) { }
            }
        }
    }
}
