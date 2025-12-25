import Foundation

enum Formatters {
    static let arabicLocale = Locale(identifier: "ar")

    static func currencyFormatter(currencyCode: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = arabicLocale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
}
