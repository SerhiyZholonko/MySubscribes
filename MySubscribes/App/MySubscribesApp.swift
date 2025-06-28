//
//  MySubscribesApp.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI
import UserNotifications
import SwiftData

@main
struct MySubscribesApp: App {
    init() {
          // Set up notification delegate
          UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
      }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Subscription.self)
        }
    }
}

// MARK: - Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationDelegate()
    
    override init() {
        super.init()
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification interaction
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let serviceName = userInfo["serviceName"] as? String,
           let amount = userInfo["amount"] as? Double {
            print("User tapped notification for \(serviceName) - $\(amount)")
            
            // You can add navigation logic here to show the specific subscription
            // or handle the payment action
        }
        
        completionHandler()
    }
}
