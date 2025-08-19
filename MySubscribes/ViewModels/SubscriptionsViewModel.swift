//
//  SubscriptionsViewModel.swift
//  MySubscribes
//
//  Created by apple on 27.06.2025.
//

//import SwiftUI
//import SwiftData
//// MARK: - ViewModels
//@MainActor
//class SubscriptionsViewModel: ObservableObject {
//    @Published var subscriptions: [Subscription] = []
//    @Published var selectedPeriod: BillingDisplayPeriod = .monthly
//    @Published var showingDeleteAlert = false
//    @Published var subscriptionToDelete: Subscription?
//    
//    private var modelContext: ModelContext?
//    
//    func setModelContext(_ context: ModelContext) {
//        self.modelContext = context
//    }
//    
//    func loadSubscriptions() {
//        guard let context = modelContext else { return }
//        
//        do {
//            let descriptor = FetchDescriptor<Subscription>()
//            subscriptions = try context.fetch(descriptor)
//        } catch {
//            print("Failed to load subscriptions: \(error)")
//        }
//    }
//    
//    func deleteSubscription(_ subscription: Subscription) {
//        guard let context = modelContext else { return }
//        
//        context.delete(subscription)
//        
//        do {
//            try context.save()
//            loadSubscriptions() // Refresh the list
//        } catch {
//            print("Failed to delete subscription: \(error)")
//        }
//    }
//    
//    func confirmDelete(_ subscription: Subscription) {
//        subscriptionToDelete = subscription
//        showingDeleteAlert = true
//    }
//    
//    var totalSpendingForPeriod: Double {
//        let monthlyTotal = subscriptions.reduce(0) { total, subscription in
//            switch subscription.billingPeriod.lowercased() {
//            case "weekly":
//                return total + (subscription.monthlyCost * 4.33) // Average weeks per month
//            case "yearly":
//                return total + (subscription.monthlyCost / 12)
//            default: // monthly
//                return total + subscription.monthlyCost
//            }
//        }
//        
//        // Convert monthly total to selected period
//        switch selectedPeriod {
//        case .weekly:
//            return monthlyTotal / 4.33
//        case .monthly:
//            return monthlyTotal
//        case .yearly:
//            return monthlyTotal * 12
//        }
//    }
//    
//    var periodTitle: String {
//        "Total \(selectedPeriod.rawValue) Spending"
//    }
//    
//    var iconForPeriod: String {
//        switch selectedPeriod {
//        case .weekly:
//            return "calendar.day.timeline.left"
//        case .monthly:
//            return "chart.bar.xaxis"
//        case .yearly:
//            return "calendar"
//        }
//    }
//}
//
//@MainActor
//class SubscriptionCellViewModel: ObservableObject {
//    let subscription: Subscription
//    
//    init(subscription: Subscription) {
//        self.subscription = subscription
//    }
//    
//    var serviceColor: Color {
//        switch subscription.serviceName.lowercased() {
//        case "netflix":
//            return .red
//        case "spotify":
//            return .green
//        case "apple music":
//            return .pink
//        case "disney+", "disney plus":
//            return .blue
//        case "hulu":
//            return .green
//        case "amazon prime":
//            return .orange
//        default:
//            return .blue
//        }
//    }
//    
//    var serviceIcon: String {
//        switch subscription.serviceName.lowercased() {
//        case "netflix":
//            return "tv"
//        case "spotify", "apple music":
//            return "music.note"
//        case "disney+", "disney plus":
//            return "star.fill"
//        case "hulu":
//            return "play.tv"
//        case "amazon prime":
//            return "shippingbox"
//        default:
//            return "star.fill"
//        }
//    }
//    
//    var daysUntilPayment: Int {
//        let calendar = Calendar.current
//        let today = Date()
//        let days = calendar.dateComponents([.day], from: today, to: subscription.nextPaymentDate).day ?? 0
//        return max(0, days)
//    }
//    
//    var formattedNextPaymentDate: String {
//        shortDateFormatter.string(from: subscription.nextPaymentDate)
//    }
//    
//    var formattedCost: String {
//        String(format: "%.2f", subscription.monthlyCost)
//    }
//    // MARK: - Date Formatters
//    private let shortDateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM d"
//        return formatter
//    }()
//}

import SwiftUI
import SwiftData

enum BillingDisplayPeriod: String, CaseIterable {
    case monthly = "Monthly"
    case yearly = "Yearly"
}

@Observable
class SubscriptionsViewModel: ObservableObject {
    var subscriptions: [Subscription] = []
    var showingDeleteAlert = false
    var subscriptionToDelete: Subscription?
    var selectedPeriod: BillingDisplayPeriod = .monthly
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func confirmDelete(_ subscription: Subscription) {
        subscriptionToDelete = subscription
        showingDeleteAlert = true
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        guard let modelContext = modelContext else { return }
        
        // Cancel notifications before deleting
        NotificationManager.shared.cancelNotifications(for: subscription)
        
        // Delete from database
        modelContext.delete(subscription)
        
        do {
            try modelContext.save()
            print("✅ Subscription deleted successfully")
        } catch {
            print("❌ Error deleting subscription: \(error)")
        }
        
        // Reset alert state
        subscriptionToDelete = nil
        showingDeleteAlert = false
    }
    
    func markPaymentAsPaid(_ subscription: Subscription) {
        guard let modelContext = modelContext else { return }
        
        // Mark payment as paid and update next payment date
        subscription.markAsPaid()
        
        // Cancel old notifications and schedule new ones for the new payment date
        NotificationManager.shared.scheduleAdvancedNotifications(for: subscription)
        
        do {
            try modelContext.save()
            print("✅ Payment marked as paid for \(subscription.serviceName)")
        } catch {
            print("❌ Error marking payment as paid: \(error)")
        }
    }
    
    // Calculate total monthly spending
    var totalMonthlySpending: Double {
        subscriptions.reduce(0) { total, subscription in
            total + subscription.monthlyCost
        }
    }
    
    // Get subscriptions due soon (within next 7 days)
    var subscriptionsDueSoon: [Subscription] {
        let sevenDaysFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return subscriptions.filter { subscription in
            subscription.nextPaymentDate <= sevenDaysFromNow && subscription.nextPaymentDate >= Date()
        }
    }
    
    // MARK: - Filtered subscriptions based on selected period
    var filteredSubscriptions: [Subscription] {
        switch selectedPeriod {
        case .monthly:
            return subscriptions.filter { $0.billingPeriod == "Monthly" }
        case .yearly:
            return subscriptions.filter { $0.billingPeriod == "Yearly" }
        }
    }
    
    // MARK: - Period-based calculations
    var totalSpendingForPeriod: Double {
        // Calculate sum only for subscriptions matching the selected period
        return filteredSubscriptions.reduce(0) { total, subscription in
            return total + subscription.monthlyCost
        }
    }
    
    var periodTitle: String {
        switch selectedPeriod {
        case .monthly:
            return "Monthly Spending"
        case .yearly:
            return "Yearly Spending"
        }
    }
    
    var iconForPeriod: String {
        switch selectedPeriod {
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.badge.clock"
        }
    }
    
}
