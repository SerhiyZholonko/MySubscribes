//
//  NotificationManager.swift
//  MySubscribes
//
//  Created by apple on 28.06.2025.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission Management
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - Schedule Advanced Notifications
    func scheduleAdvancedNotifications(for subscription: Subscription) {
        requestPermission { [weak self] granted in
            if granted {
                self?.createAdvancedNotificationRequests(for: subscription)
            }
        }
    }
    
    private func getNextPaymentDate(from date: Date, period: String, using calendar: Calendar) -> Date? {
        // Normalize input date to start of day to avoid timezone issues
        let normalizedDate = calendar.startOfDay(for: date)
        
        switch period {
        case "Weekly":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: normalizedDate)
        case "Monthly":
            return calendar.date(byAdding: .month, value: 1, to: normalizedDate)
        case "Quarterly":
            return calendar.date(byAdding: .month, value: 3, to: normalizedDate)
        case "Yearly":
            return calendar.date(byAdding: .year, value: 1, to: normalizedDate)
        default:
            return nil
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelNotifications(for subscription: Subscription) {
        let center = UNUserNotificationCenter.current()
        let baseIdentifier = generateNotificationId(for: subscription)
        
        var identifiersToCancel: [String] = []
        
        // Cancel main notifications
        identifiersToCancel.append(baseIdentifier)
        identifiersToCancel.append("\(baseIdentifier)_reminder")
        identifiersToCancel.append("\(baseIdentifier)_renewal")
        identifiersToCancel.append("\(baseIdentifier)_expired")
        
        // Cancel recurring notifications (up to max possible based on billing period)
        let maxNotifications = calculateMaxNotifications(for: subscription.billingPeriod)
        for i in 1...maxNotifications {
            identifiersToCancel.append("\(baseIdentifier)_reminder_\(i)")
            identifiersToCancel.append("\(baseIdentifier)_payment_\(i)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        
        print("🗑️ Cancelled all notifications for \(subscription.serviceName) (including renewals and recurring)")
    }
    
    // MARK: - Advanced Notification Creation
    private func createAdvancedNotificationRequests(for subscription: Subscription) {
        // Cancel existing notifications first
        cancelNotifications(for: subscription)
        
        // Schedule reminder notification
        scheduleReminderNotification(for: subscription)
        
        // Schedule payment due notification
        schedulePaymentDueNotification(for: subscription)
        
        // Schedule recurring notifications if applicable
        if subscription.isRecurring {
            scheduleRecurringAdvancedNotifications(for: subscription)
        }
    }
    
    private func scheduleReminderNotification(for subscription: Subscription) {
        let calendar = Calendar.current
        let normalizedPaymentDate = calendar.startOfDay(for: subscription.nextPaymentDate)
        let reminderDate = calendar.date(
            byAdding: .day,
            value: -subscription.reminderDays,
            to: normalizedPaymentDate
        ) ?? normalizedPaymentDate
        
        // Don't schedule reminder if it's in the past
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🔔 Payment Reminder"
        content.body = "\(subscription.serviceName) payment of $\(String(format: "%.2f", subscription.monthlyCost)) is due in \(subscription.reminderDays) day\(subscription.reminderDays == 1 ? "" : "s")"
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost,
            "type": "reminder"
        ]
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "\(generateNotificationId(for: subscription))_reminder"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling reminder notification: \(error)")
            } else {
                print("✅ Reminder notification scheduled for \(subscription.serviceName)")
            }
        }
    }
    
    private func schedulePaymentDueNotification(for subscription: Subscription) {
        let content = UNMutableNotificationContent()
        content.title = "💳 Payment Due Today"
        content.body = "\(subscription.serviceName) payment of $\(String(format: "%.2f", subscription.monthlyCost)) is due today!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SUBSCRIPTION_PAYMENT"
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost,
            "category": subscription.category,
            "type": "payment_due"
        ]
        
        let calendar = Calendar.current
        let normalizedPaymentDate = calendar.startOfDay(for: subscription.nextPaymentDate)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: normalizedPaymentDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = generateNotificationId(for: subscription)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling payment notification: \(error)")
            } else {
                print("✅ Payment notification scheduled for \(subscription.serviceName)")
            }
        }
    }
    
    private func scheduleRecurringAdvancedNotifications(for subscription: Subscription) {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: subscription.nextPaymentDate)
        let endDate = subscription.endDate
        
        // Calculate how many notifications to schedule based on billing period
        let maxNotifications = calculateMaxNotifications(for: subscription.billingPeriod)
        
        // Schedule recurring payment notifications
        for i in 1...maxNotifications {
            guard let nextDate = getNextPaymentDate(from: currentDate, period: subscription.billingPeriod, using: calendar) else {
                break
            }
            
            // Check if we've passed the end date
            if let endDate = endDate, nextDate > endDate {
                break
            }
            
            // Schedule reminder notification
            let reminderDate = calendar.date(byAdding: .day, value: -subscription.reminderDays, to: nextDate)
            if let reminderDate = reminderDate, reminderDate > Date() {
                scheduleRecurringReminder(for: subscription, date: reminderDate, index: i)
            }
            
            // Schedule payment due notification
            scheduleRecurringPayment(for: subscription, date: nextDate, index: i)
            
            currentDate = nextDate
        }
        
        // Schedule renewal reminder if enabled and has end date
        if subscription.renewalReminderEnabled, let endDate = endDate {
            scheduleRenewalReminder(for: subscription, endDate: endDate)
        }
    }
    
    // Calculate optimal number of notifications based on billing period to cover ~1 year
    private func calculateMaxNotifications(for billingPeriod: String) -> Int {
        switch billingPeriod {
        case "Weekly":
            return 52 // 1 year of weekly notifications
        case "Monthly":
            return 12 // 1 year of monthly notifications
        case "Quarterly":
            return 4 // 1 year of quarterly notifications
        case "Yearly":
            return 2 // 2 years of yearly notifications
        default:
            return 12 // Default to monthly
        }
    }
    
    private func scheduleRecurringReminder(for subscription: Subscription, date: Date, index: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Payment Reminder"
        content.body = "\(subscription.serviceName) payment of $\(String(format: "%.2f", subscription.monthlyCost)) is due in \(subscription.reminderDays) day\(subscription.reminderDays == 1 ? "" : "s")"
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost,
            "recurringIndex": index,
            "type": "reminder"
        ]
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "\(generateNotificationId(for: subscription))_reminder_\(index)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling recurring reminder \(index): \(error)")
            } else {
                print("✅ Recurring reminder \(index) scheduled for \(subscription.serviceName)")
            }
        }
    }
    
    private func scheduleRecurringPayment(for subscription: Subscription, date: Date, index: Int) {
        let content = UNMutableNotificationContent()
        content.title = "💳 Payment Due Today"
        content.body = "\(subscription.serviceName) payment of $\(String(format: "%.2f", subscription.monthlyCost)) is due today!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SUBSCRIPTION_PAYMENT"
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost,
            "category": subscription.category,
            "recurringIndex": index,
            "type": "payment_due"
        ]
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "\(generateNotificationId(for: subscription))_payment_\(index)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling recurring payment \(index): \(error)")
            } else {
                print("✅ Recurring payment \(index) scheduled for \(subscription.serviceName)")
            }
        }
    }
    
    // MARK: - Renewal Reminder
    private func scheduleRenewalReminder(for subscription: Subscription, endDate: Date) {
        let calendar = Calendar.current
        let reminderDate = calendar.date(byAdding: .day, value: -subscription.renewalReminderDays, to: endDate)
        
        // Don't schedule if reminder date is in the past
        guard let reminderDate = reminderDate, reminderDate > Date() else { return }
        
        // Schedule renewal reminder notification
        let content = UNMutableNotificationContent()
        content.title = "🔄 Subscription Renewal Reminder"
        content.body = "Your \(subscription.serviceName) subscription expires on \(formatDate(endDate)). Don't forget to renew!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SUBSCRIPTION_RENEWAL"
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost,
            "category": subscription.category,
            "endDate": endDate.timeIntervalSince1970,
            "type": "renewal_reminder"
        ]
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "\(generateNotificationId(for: subscription))_renewal"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling renewal reminder: \(error)")
            } else {
                print("✅ Renewal reminder scheduled for \(subscription.serviceName) (\(subscription.renewalReminderDays) days before expiry)")
            }
        }
        
        // Schedule final expiry notification
        scheduleExpiryNotification(for: subscription, endDate: endDate)
    }
    
    private func scheduleExpiryNotification(for subscription: Subscription, endDate: Date) {
        // Don't schedule if expiry date is in the past
        guard endDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Subscription Expired"
        content.body = "Your \(subscription.serviceName) subscription has expired today. Renew to continue access."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SUBSCRIPTION_EXPIRED"
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost,
            "category": subscription.category,
            "type": "subscription_expired"
        ]
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = "\(generateNotificationId(for: subscription))_expired"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling expiry notification: \(error)")
            } else {
                print("✅ Expiry notification scheduled for \(subscription.serviceName)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Helper Methods
    private func generateNotificationId(for subscription: Subscription) -> String {
        return "\(subscription.serviceName.replacingOccurrences(of: " ", with: "_"))_\(subscription.nextPaymentDate.timeIntervalSince1970)"
    }
    
    // MARK: - Check Notification Status
    func checkNotificationSettings(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}
