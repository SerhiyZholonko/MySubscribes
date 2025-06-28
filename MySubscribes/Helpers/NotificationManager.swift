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
    
    // MARK: - Schedule Notifications
    func scheduleSubscriptionNotification(for subscription: Subscription) {
        requestPermission { [weak self] granted in
            if granted {
                self?.createNotificationRequest(for: subscription)
            }
        }
    }
    
    private func createNotificationRequest(for subscription: Subscription) {
        let content = UNMutableNotificationContent()
        content.title = "💳 Subscription Payment Due"
        content.body = "\(subscription.serviceName) payment of $\(String(format: "%.2f", subscription.monthlyCost)) is due today!"
        content.sound = .default
        content.badge = 1
        
        // Add custom data to identify the subscription
        content.userInfo = [
            "subscriptionId": subscription.persistentModelID.hashValue,
            "serviceName": subscription.serviceName,
            "amount": subscription.monthlyCost
        ]
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: subscription.nextPaymentDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let identifier = generateNotificationId(for: subscription)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled for \(subscription.serviceName) on \(subscription.nextPaymentDate)")
            }
        }
        
        // Schedule recurring notifications if applicable
        if subscription.billingPeriod != "One-time" {
            scheduleRecurringNotifications(for: subscription)
        }
    }
    
    private func scheduleRecurringNotifications(for subscription: Subscription) {
        let calendar = Calendar.current
        var currentDate = subscription.nextPaymentDate
        
        // Schedule up to 12 future notifications (1 year ahead)
        for i in 1...12 {
            guard let nextDate = getNextPaymentDate(from: currentDate, period: subscription.billingPeriod, using: calendar) else {
                break
            }
            
            let content = UNMutableNotificationContent()
            content.title = "💳 Subscription Payment Due"
            content.body = "\(subscription.serviceName) payment of $\(String(format: "%.2f", subscription.monthlyCost)) is due today!"
            content.sound = .default
            content.badge = 1
            content.userInfo = [
                "subscriptionId": subscription.persistentModelID.hashValue,
                "serviceName": subscription.serviceName,
                "amount": subscription.monthlyCost,
                "recurringIndex": i
            ]
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = "\(generateNotificationId(for: subscription))_recurring_\(i)"
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling recurring notification \(i): \(error)")
                } else {
                    print("✅ Recurring notification \(i) scheduled for \(subscription.serviceName) on \(nextDate)")
                }
            }
            
            currentDate = nextDate
        }
    }
    
    private func getNextPaymentDate(from date: Date, period: String, using calendar: Calendar) -> Date? {
        switch period {
        case "Weekly":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case "Monthly":
            return calendar.date(byAdding: .month, value: 1, to: date)
        case "Quarterly":
            return calendar.date(byAdding: .month, value: 3, to: date)
        case "Yearly":
            return calendar.date(byAdding: .year, value: 1, to: date)
        default:
            return nil
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelNotifications(for subscription: Subscription) {
        let center = UNUserNotificationCenter.current()
        let baseIdentifier = generateNotificationId(for: subscription)
        
        // Cancel the main notification
        center.removePendingNotificationRequests(withIdentifiers: [baseIdentifier])
        
        // Cancel recurring notifications
        var identifiersToCancel: [String] = []
        for i in 1...12 {
            identifiersToCancel.append("\(baseIdentifier)_recurring_\(i)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        
        print("🗑️ Cancelled notifications for \(subscription.serviceName)")
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
