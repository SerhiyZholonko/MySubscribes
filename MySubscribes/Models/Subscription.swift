//
//  Subscription.swift
//  MySubscribes
//
//  Created by apple on 25.06.2025.
//



import SwiftUI
import SwiftData

// MARK: - SwiftData Model
@Model
final class Subscription {
    var serviceName: String = ""
    var monthlyCost: Double = 0.0
    var billingPeriod: String = "Monthly"
    var nextPaymentDate: Date = Date()
    var createdDate: Date = Date()
    var isRecurring: Bool = true
    var endDate: Date? = nil
    var reminderDays: Int = 1 // Days before payment to send reminder
    var category: String = "General"
    var notes: String = ""
    var color: String = "blue" // For calendar visualization
    
    init(serviceName: String, monthlyCost: Double, billingPeriod: String, nextPaymentDate: Date, isRecurring: Bool = true, endDate: Date? = nil, reminderDays: Int = 1, category: String = "General", notes: String = "", color: String = "blue") {
        self.serviceName = serviceName
        self.monthlyCost = monthlyCost
        self.billingPeriod = billingPeriod
        self.nextPaymentDate = nextPaymentDate
        self.isRecurring = isRecurring
        self.endDate = endDate
        self.reminderDays = reminderDays
        self.category = category
        self.notes = notes
        self.color = color
        self.createdDate = Date()
    }
    
    // Empty initializer for SwiftData
    init() {}
    
    // Helper computed properties
    var isActive: Bool {
        if let endDate = endDate {
            return Date() <= endDate
        }
        return true
    }
    
    var displayColor: Color {
        switch color {
        case "red": return DesignSystem.Colors.netflix
        case "green": return DesignSystem.Colors.spotify
        case "blue": return DesignSystem.Colors.apple
        case "orange": return DesignSystem.Colors.amazon
        case "purple": return DesignSystem.Colors.primary
        default: return DesignSystem.Colors.primary
        }
    }
}









