import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleLimitAlert(categoryName: String, remainingPercentage: Double) {
        let content = UNMutableNotificationContent()
        content.title = "تنبيه لطيف"
        content.body = "اقتربت من حد فئة \(categoryName). المتبقي \(Int(remainingPercentage * 100))٪."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "limit-\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleRecurringBillReminder(bill: RecurringBill) {
        guard bill.isActive else { return }
        var dateComponents = DateComponents()
        dateComponents.day = bill.dueDay
        dateComponents.hour = 9
        let content = UNMutableNotificationContent()
        content.title = "تذكير فاتورة"
        content.body = "لا تنس دفع \(bill.name) بقيمة \(bill.amount)."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "bill-\(bill.id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelRecurringBillReminder(bill: RecurringBill) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bill-\(bill.id.uuidString)"])
    }
}
