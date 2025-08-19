//
//  EditSubscriptionViewModel.swift
//  MySubscribes
//
//  Created by Claude on 06.08.2025.
//

import SwiftUI
import SwiftData
import UserNotifications

class EditSubscriptionViewModel: ObservableObject {
    @Published var serviceNameText: String = ""
    @Published var monthlyCostText: String = "0.00"
    @Published var selectedPeriod = "Monthly"
    @Published var nextPaymentDate = Date()
    @Published var selectedCategory = "General"
    @Published var notes = ""
    @Published var selectedColor = "blue"
    @Published var reminderDays = 1
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var shouldDismiss = false
    
    private var modelContext: ModelContext?
    private let originalSubscription: Subscription
    
    let categories = ["General", "Entertainment", "Software", "Health", "Education", "Shopping", "Utilities", "Gaming"]
    let colors = ["blue", "purple", "red", "green", "orange"]
    let reminderOptions = [
        (1, "1 day before"),
        (3, "3 days before"),
        (7, "1 week before"),
        (14, "2 weeks before")
    ]
    
    init(subscription: Subscription) {
        self.originalSubscription = subscription
        
        // Populate fields with current subscription data
        self.serviceNameText = subscription.serviceName
        self.monthlyCostText = String(format: "%.2f", subscription.monthlyCost)
        self.selectedPeriod = subscription.billingPeriod
        self.nextPaymentDate = subscription.nextPaymentDate
        self.selectedCategory = subscription.category
        self.notes = subscription.notes
        self.selectedColor = subscription.color
        self.reminderDays = subscription.reminderDays
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func refreshData() {
        // Re-populate fields with current subscription data to ensure fresh state
        self.serviceNameText = originalSubscription.serviceName
        self.monthlyCostText = String(format: "%.2f", originalSubscription.monthlyCost)
        self.selectedPeriod = originalSubscription.billingPeriod
        self.nextPaymentDate = originalSubscription.nextPaymentDate
        self.selectedCategory = originalSubscription.category
        self.notes = originalSubscription.notes
        self.selectedColor = originalSubscription.color
        self.reminderDays = originalSubscription.reminderDays
        
        // Reset alert states
        self.showingAlert = false
        self.alertMessage = ""
        self.shouldDismiss = false
    }
    
    func updateSubscription() {
        guard validateInput() else { return }
        
        guard let cost = Double(monthlyCostText), cost > 0 else {
            showAlert(message: "Please enter a valid cost")
            return
        }
        
        guard let modelContext = modelContext else {
            showAlert(message: "Database context not available")
            return
        }
        
        // Update the subscription properties
        originalSubscription.serviceName = serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines)
        originalSubscription.monthlyCost = cost
        originalSubscription.billingPeriod = selectedPeriod
        originalSubscription.nextPaymentDate = normalizeDate(nextPaymentDate)
        originalSubscription.category = selectedCategory
        originalSubscription.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        originalSubscription.color = selectedColor
        originalSubscription.reminderDays = reminderDays
        
        // Reset payment status if payment date changed significantly
        let calendar = Calendar.current
        if !calendar.isDate(originalSubscription.nextPaymentDate, inSameDayAs: nextPaymentDate) {
            originalSubscription.isCurrentPaymentPaid = false
        }
        
        // Cancel existing notifications and schedule new ones
        NotificationManager.shared.scheduleAdvancedNotifications(for: originalSubscription)
        
        do {
            try modelContext.save()
            showAlert(message: "Subscription updated successfully!") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.shouldDismiss = true
                }
            }
        } catch {
            showAlert(message: "Failed to update subscription: \(error.localizedDescription)")
        }
    }
    
    private func validateInput() -> Bool {
        guard !serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Please enter a service name")
            return false
        }
        return true
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        alertMessage = message
        showingAlert = true
        completion?()
    }
}