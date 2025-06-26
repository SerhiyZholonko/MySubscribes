//
//  AddSubscriptionViewModel.swift
//  MySubscribes
//
//  Created by apple on 26.06.2025.
//

import SwiftUI
import SwiftData

// MARK: - ViewModel
@Observable
class AddSubscriptionViewModel {
    var serviceNameText: String = ""
    var monthlyCostText: String = "0.00"
    var selectedPeriod = "Monthly"
    var nextPaymentDate = Date()
    var showingAlert = false
    var alertMessage = ""
    var shouldDismiss = false
    
    private var modelContext: ModelContext?
    
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
            nextPaymentDate: nextPaymentDate
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
        showingAlert = false
        alertMessage = ""
        shouldDismiss = false
    }
}
