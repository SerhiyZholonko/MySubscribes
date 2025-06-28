//
//  SubscriptionCellViewModel.swift
//  MySubscribes
//
//  Created by apple on 28.06.2025.
//

import SwiftUI
import Foundation

class SubscriptionCellViewModel: ObservableObject {
    private let subscription: Subscription
    
    init(subscription: Subscription) {
        self.subscription = subscription
    }
    
    // MARK: - Computed Properties
    
    var formattedCost: String {
        return String(format: "%.2f", subscription.monthlyCost)
    }
    
    var formattedNextPaymentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: subscription.nextPaymentDate)
    }
    
    var daysUntilPayment: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let paymentDate = calendar.startOfDay(for: subscription.nextPaymentDate)
        
        let components = calendar.dateComponents([.day], from: today, to: paymentDate)
        return components.day ?? 0
    }
    
    var serviceColor: Color {
        return getServiceColor(for: subscription.serviceName)
    }
    
    var serviceIcon: String {
        return getServiceIcon(for: subscription.serviceName)
    }
    
    // MARK: - Helper Methods
    
    private func getServiceColor(for serviceName: String) -> Color {
        let lowercasedName = serviceName.lowercased()
        
        switch lowercasedName {
        case let name where name.contains("netflix"):
            return .red
        case let name where name.contains("spotify"):
            return .green
        case let name where name.contains("apple"):
            return .black
        case let name where name.contains("disney"):
            return .blue
        case let name where name.contains("amazon"):
            return .orange
        case let name where name.contains("youtube"):
            return .red
        case let name where name.contains("hulu"):
            return .green
        case let name where name.contains("adobe"):
            return .red
        case let name where name.contains("microsoft"):
            return .blue
        case let name where name.contains("google"):
            return .blue
        case let name where name.contains("dropbox"):
            return .blue
        case let name where name.contains("github"):
            return .black
        case let name where name.contains("slack"):
            return .purple
        case let name where name.contains("zoom"):
            return .blue
        default:
            // Generate a consistent color based on the service name hash
            let hash = serviceName.hashValue
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal, .indigo, .cyan]
            return colors[abs(hash) % colors.count]
        }
    }
    
    private func getServiceIcon(for serviceName: String) -> String {
        let lowercasedName = serviceName.lowercased()
        
        switch lowercasedName {
        case let name where name.contains("netflix"):
            return "tv.fill"
        case let name where name.contains("spotify"):
            return "music.note"
        case let name where name.contains("apple"):
            return "applelogo"
        case let name where name.contains("disney"):
            return "tv.fill"
        case let name where name.contains("amazon"):
            return "shippingbox.fill"
        case let name where name.contains("youtube"):
            return "play.rectangle.fill"
        case let name where name.contains("hulu"):
            return "tv.fill"
        case let name where name.contains("adobe"):
            return "paintbrush.fill"
        case let name where name.contains("microsoft"):
            return "building.2.fill"
        case let name where name.contains("google"):
            return "globe"
        case let name where name.contains("dropbox"):
            return "icloud.fill"
        case let name where name.contains("github"):
            return "chevron.left.forwardslash.chevron.right"
        case let name where name.contains("slack"):
            return "message.fill"
        case let name where name.contains("zoom"):
            return "video.fill"
        case let name where name.contains("gym"), let name where name.contains("fitness"):
            return "figure.run"
        case let name where name.contains("bank"), let name where name.contains("credit"):
            return "creditcard.fill"
        case let name where name.contains("insurance"):
            return "shield.fill"
        case let name where name.contains("phone"), let name where name.contains("mobile"):
            return "iphone"
        case let name where name.contains("internet"), let name where name.contains("wifi"):
            return "wifi"
        case let name where name.contains("electric"), let name where name.contains("power"):
            return "bolt.fill"
        case let name where name.contains("gas"):
            return "flame.fill"
        case let name where name.contains("water"):
            return "drop.fill"
        case let name where name.contains("rent"), let name where name.contains("mortgage"):
            return "house.fill"
        case let name where name.contains("car"), let name where name.contains("auto"):
            return "car.fill"
        case let name where name.contains("food"), let name where name.contains("meal"):
            return "fork.knife"
        case let name where name.contains("coffee"):
            return "cup.and.saucer.fill"
        case let name where name.contains("news"), let name where name.contains("magazine"):
            return "newspaper.fill"
        case let name where name.contains("game"), let name where name.contains("gaming"):
            return "gamecontroller.fill"
        case let name where name.contains("cloud"), let name where name.contains("storage"):
            return "icloud.fill"
        case let name where name.contains("vpn"):
            return "lock.shield.fill"
        case let name where name.contains("email"), let name where name.contains("mail"):
            return "envelope.fill"
        case let name where name.contains("calendar"):
            return "calendar"
        case let name where name.contains("note"), let name where name.contains("task"):
            return "note.text"
        case let name where name.contains("photo"):
            return "photo.fill"
        case let name where name.contains("video"):
            return "video.fill"
        case let name where name.contains("music"):
            return "music.note"
        case let name where name.contains("book"), let name where name.contains("read"):
            return "book.fill"
        case let name where name.contains("learn"), let name where name.contains("education"):
            return "graduationcap.fill"
        case let name where name.contains("health"), let name where name.contains("medical"):
            return "cross.fill"
        case let name where name.contains("travel"):
            return "airplane"
        case let name where name.contains("taxi"), let name where name.contains("uber"), let name where name.contains("lyft"):
            return "car.fill"
        case let name where name.contains("delivery"):
            return "shippingbox.fill"
        default:
            return "app.fill"
        }
    }
}
