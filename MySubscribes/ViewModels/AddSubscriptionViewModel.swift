
//  AddSubscriptionViewModel.swift
//  MySubscribes
//
//  Created by apple on 26.06.2025.


import SwiftUI
import SwiftData
import UserNotifications

// MARK: - ViewModel
@Observable
class AddSubscriptionViewModel {
    var serviceNameText: String = ""
    var monthlyCostText: String = "0.00"
    var selectedPeriod = "Monthly"
    var nextPaymentDate = Date()
    var isRecurring = true
    var endDate: Date? = nil
    var reminderDays = 1
    var selectedCategory = "General"
    var notes = ""
    var selectedColor = "blue"
    var showingAlert = false
    var alertMessage = ""
    var shouldDismiss = false
    
    private var modelContext: ModelContext?
    
    let categories = ["General", "Entertainment", "Software", "Health", "Education", "Shopping", "Utilities", "Gaming"]
    let colors = ["blue", "purple", "red", "green", "orange"]
    let reminderOptions = [
        (1, "1 day before"),
        (3, "3 days before"),
        (7, "1 week before"),
        (14, "2 weeks before")
    ]
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func saveSubscription() {
        guard validateInput() else { return }
        
        guard let cost = Double(monthlyCostText), cost > 0 else {
            showAlert(message: "Please enter a valid monthly cost")
            return
        }
        
        let subscription = Subscription(
            serviceName: serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines),
            monthlyCost: cost,
            billingPeriod: selectedPeriod,
            nextPaymentDate: nextPaymentDate,
            isRecurring: isRecurring,
            endDate: isRecurring ? endDate : nil,
            reminderDays: reminderDays,
            category: selectedCategory,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            color: selectedColor
        )
        
        saveToDatabase(subscription: subscription)
    }
    
    private func validateInput() -> Bool {
        
        guard !serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Please enter a service name")
            return false
        }
        return true
    }
    
    private func saveToDatabase(subscription: Subscription) {
        guard let modelContext = modelContext else {
            showAlert(message: "Database context not available")
            return
        }
        
        modelContext.insert(subscription)
        
        do {
            try modelContext.save()
            
            // Schedule advanced notifications after successful save
            NotificationManager.shared.scheduleAdvancedNotifications(for: subscription)
            
            showAlert(message: "Subscription saved successfully!") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.resetForm()
                    self.shouldDismiss = true
                }
            }
        } catch {
            showAlert(message: "Failed to save subscription: \(error.localizedDescription)")
        }
    }
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        alertMessage = message
        showingAlert = true
        completion?()
    }
    
    func resetForm() {
        serviceNameText = ""
        monthlyCostText = "0.00"
        selectedPeriod = "Monthly"
        nextPaymentDate = Date()
        isRecurring = true
        endDate = nil
        reminderDays = 1
        selectedCategory = "General"
        notes = ""
        selectedColor = "blue"
        showingAlert = false
        alertMessage = ""
        shouldDismiss = false
    }
}
