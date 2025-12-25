import Foundation
import SwiftUI
import SwiftData

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("selectedCurrency") var selectedCurrency: String = CurrencyOption.sar.rawValue
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @Published var useSampleData: Bool = false
    @Published var exportData: Data?
    @Published var showExportError: Bool = false
    @Published var showImportError: Bool = false
    @Published var message: String = ""

    func ensureDefaults(context: ModelContext) {
        let count = (try? context.fetch(FetchDescriptor<Category>()).count) ?? 0
        if count == 0 {
            SeedData.addDefaultCategories(to: context)
            try? context.save()
        }
    }

    func applySampleData(context: ModelContext) {
        if useSampleData {
            SeedData.addSampleData(to: context)
            try? context.save()
        }
    }

    func exportBackup(context: ModelContext) {
        do {
            exportData = try BackupManager().exportData(from: context)
        } catch {
            message = "تعذر إنشاء نسخة احتياطية. حاول مرة أخرى."
            showExportError = true
        }
    }

    func importBackup(data: Data, context: ModelContext) {
        do {
            try BackupManager().importData(data, into: context)
            message = "تمت استعادة البيانات بنجاح."
            showImportError = false
        } catch {
            message = "تعذر استعادة النسخة الاحتياطية. تحقق من الملف."
            showImportError = true
        }
    }
}
