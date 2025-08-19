//
//  EditSubscriptionView.swift
//  MySubscribes
//
//  Created by Claude on 06.08.2025.
//

import SwiftUI
import SwiftData
import UserNotifications

struct EditSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let subscription: Subscription
    
    // Direct state variables with default values
    @State private var serviceNameText = ""
    @State private var monthlyCostText = "0.00"
    @State private var selectedPeriod = "Monthly"
    @State private var nextPaymentDate = Date()
    @State private var selectedCategory = "General"
    @State private var notes = ""
    @State private var selectedColor = "blue"
    @State private var reminderDays = 1
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let categories = ["General", "Entertainment", "Software", "Health", "Education", "Shopping", "Utilities", "Gaming"]
    let colors = ["blue", "purple", "red", "green", "orange"]
    let reminderOptions = [
        (1, "1 day before"),
        (3, "3 days before"),
        (7, "1 week before"),
        (14, "2 weeks before")
    ]
    
    init(subscription: Subscription) {
        self.subscription = subscription
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Service Info") {
                    TextField("Service Name", text: $serviceNameText)
                    TextField("Cost", text: $monthlyCostText)
                        .keyboardType(.decimalPad)
                }
                
                Section("Billing") {
                    Picker("Billing Period", selection: $selectedPeriod) {
                        ForEach(["Weekly", "Monthly", "Quarterly", "Yearly"], id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    DatePicker("Next Payment", selection: $nextPaymentDate, displayedComponents: .date)
                }
                
                Section("Category & Notes") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Reminder") {
                    Picker("Reminder", selection: $reminderDays) {
                        ForEach(reminderOptions, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }
                }
            }
            .navigationTitle("Edit Subscription")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateSubscription()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                loadSubscriptionData()
            }
            .alert("Result", isPresented: $showingAlert) {
                Button("OK") { 
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadSubscriptionData() {
        serviceNameText = subscription.serviceName
        monthlyCostText = String(format: "%.2f", subscription.monthlyCost)
        selectedPeriod = subscription.billingPeriod
        nextPaymentDate = subscription.nextPaymentDate
        selectedCategory = subscription.category
        notes = subscription.notes
        selectedColor = subscription.color
        reminderDays = subscription.reminderDays
    }
    
    private func updateSubscription() {
        guard !serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Please enter a service name")
            return
        }
        
        guard let cost = Double(monthlyCostText), cost > 0 else {
            showAlert(message: "Please enter a valid cost")
            return
        }
        
        subscription.serviceName = serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.monthlyCost = cost
        subscription.billingPeriod = selectedPeriod
        subscription.nextPaymentDate = nextPaymentDate
        subscription.category = selectedCategory
        subscription.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.color = selectedColor
        subscription.reminderDays = reminderDays
        
        NotificationManager.shared.scheduleAdvancedNotifications(for: subscription)
        
        do {
            try modelContext.save()
            showAlert(message: "Successfully updated!")
        } catch {
            showAlert(message: "Error: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

#Preview {
    EditSubscriptionView(subscription: Subscription(
        serviceName: "Netflix",
        monthlyCost: 15.99,
        billingPeriod: "Monthly",
        nextPaymentDate: Date()
    ))
}