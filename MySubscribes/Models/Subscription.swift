//
//  Subscription.swift
//  MySubscribes
//
//  Created by apple on 25.06.2025.
//



import SwiftUI
import SwiftData

// MARK: - Payment Status Enum
enum PaymentStatus: String, CaseIterable {
    case paid = "Paid"
    case upcoming = "Upcoming"
    case dueSoon = "Due Soon"
    case overdue = "Overdue"
    
    var color: Color {
        switch self {
        case .paid:
            return DesignSystem.Colors.success
        case .upcoming:
            return DesignSystem.Colors.textSecondary
        case .dueSoon:
            return DesignSystem.Colors.warning
        case .overdue:
            return DesignSystem.Colors.error
        }
    }
    
    var icon: String {
        switch self {
        case .paid:
            return "checkmark.circle.fill"
        case .upcoming:
            return "clock"
        case .dueSoon:
            return "exclamationmark.triangle.fill"
        case .overdue:
            return "xmark.circle.fill"
        }
    }
}

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
    var renewalReminderEnabled: Bool = true // Enable renewal reminders when subscription ends
    var renewalReminderDays: Int = 7 // Days before end date to remind about renewal
    var category: String = "General"
    var notes: String = ""
    var color: String = "blue" // For calendar visualization
    var lastPaymentDate: Date? = nil // Date of last payment
    var paymentHistory: [Date] = [] // History of payment dates
    var isCurrentPaymentPaid: Bool = false // Whether current payment is marked as paid
    
    init(serviceName: String, monthlyCost: Double, billingPeriod: String, nextPaymentDate: Date, isRecurring: Bool = true, endDate: Date? = nil, reminderDays: Int = 1, renewalReminderEnabled: Bool = true, renewalReminderDays: Int = 7, category: String = "General", notes: String = "", color: String = "blue") {
        self.serviceName = serviceName
        self.monthlyCost = monthlyCost
        self.billingPeriod = billingPeriod
        self.nextPaymentDate = nextPaymentDate
        self.isRecurring = isRecurring
        self.endDate = endDate
        self.reminderDays = reminderDays
        self.renewalReminderEnabled = renewalReminderEnabled
        self.renewalReminderDays = renewalReminderDays
        self.category = category
        self.notes = notes
        self.color = color
        self.createdDate = Date()
        self.lastPaymentDate = nil
        self.paymentHistory = []
        self.isCurrentPaymentPaid = false
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
    
    // MARK: - Payment Methods
    func markAsPaid() {
        let now = Date()
        isCurrentPaymentPaid = true
        lastPaymentDate = now
        paymentHistory.append(now)
        
        // Calculate next payment date based on billing period
        updateNextPaymentDate()
    }
    
    func updateNextPaymentDate() {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: nextPaymentDate)
        
        switch billingPeriod {
        case "Weekly":
            nextPaymentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        case "Monthly":
            nextPaymentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        case "Quarterly":
            nextPaymentDate = calendar.date(byAdding: .month, value: 3, to: currentDate) ?? currentDate
        case "Yearly":
            nextPaymentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
        default:
            nextPaymentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        // Reset payment status for new period
        isCurrentPaymentPaid = false
    }
    
    var isPastDue: Bool {
        return nextPaymentDate < Date() && !isCurrentPaymentPaid
    }
    
    var daysUntilPayment: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let paymentDate = calendar.startOfDay(for: nextPaymentDate)
        let days = calendar.dateComponents([.day], from: today, to: paymentDate).day ?? 0
        return days
    }
    
    var paymentStatus: PaymentStatus {
        if isCurrentPaymentPaid {
            return .paid
        } else if isPastDue {
            return .overdue
        } else if daysUntilPayment <= 3 {
            return .dueSoon
        } else {
            return .upcoming
        }
    }
}









