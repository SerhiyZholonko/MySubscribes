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
    
    init(serviceName: String, monthlyCost: Double, billingPeriod: String, nextPaymentDate: Date) {
        self.serviceName = serviceName
        self.monthlyCost = monthlyCost
        self.billingPeriod = billingPeriod
        self.nextPaymentDate = nextPaymentDate
        self.createdDate = Date()
    }
    
    // Empty initializer for SwiftData
    init() {}
}

// MARK: - Main View
struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var serviceNameText: String = ""
    @State private var monthlyCostText: String = "0.00"
    @State private var selectedPeriod = "Monthly"
    @State private var nextPaymentDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            ASHeaderView(onSave: saveSubscription, onCancel: { dismiss() })
            ZStack(alignment: .top) {
                Color(.blue)
                    .opacity(0.1)
                ScrollView {
                    ServiceNameView(serviceNameText: $serviceNameText)
                    MonthlyCostView(monthlyCostText: $monthlyCostText)
                    BillingPeriodView(selectedPeriod: $selectedPeriod)
                    NextPaymentDateView(nextPaymentDate: $nextPaymentDate)
                }
            }
        }
        .alert("Subscription", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveSubscription() {
        // Validation
        guard !serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Please enter a service name")
            return
        }
        
        guard let cost = Double(monthlyCostText), cost > 0 else {
            showAlert(message: "Please enter a valid monthly cost")
            return
        }
        
        // Create and save subscription
        let subscription = Subscription(
            serviceName: serviceNameText.trimmingCharacters(in: .whitespacesAndNewlines),
            monthlyCost: cost,
            billingPeriod: selectedPeriod,
            nextPaymentDate: nextPaymentDate
        )
        
        modelContext.insert(subscription)
        
        do {
            try modelContext.save()
            showAlert(message: "Subscription saved successfully!") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
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
}

// MARK: - Header View
struct ASHeaderView: View {
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(.gray)
            }
            .padding(.trailing, 30)
            .padding(.leading)
            
            Text("Add Subscription")
                .font(.system(size: 24, weight: .semibold, design: .default))
            
            Spacer()
            
            Button("Save", action: onSave)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.trailing)
    }
}

// MARK: - Service Name View
struct ServiceNameView: View {
    @Binding var serviceNameText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Service Name")
            TextField("e.g., Netflix, Spotify", text: $serviceNameText)
                .frame(height: 50)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding()
    }
}

// MARK: - Monthly Cost View
struct MonthlyCostView: View {
    @Binding var monthlyCostText: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Cost")
            
            HStack {
                TextField("$ 0.00", text: $monthlyCostText)
                    .keyboardType(.decimalPad)
                
                VStack(spacing: 0) {
                    Button(action: { incrementCost() }) {
                        Image(systemName: "chevron.up")
                    }
                    Button(action: { decrementCost() }) {
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
    }
    
    func incrementCost() {
        if let value = Double(monthlyCostText) {
            monthlyCostText = String(format: "%.2f", value + 1)
        }
    }

    func decrementCost() {
        if let value = Double(monthlyCostText), value > 0 {
            monthlyCostText = String(format: "%.2f", value - 1)
        }
    }
}

// MARK: - Billing Period View
struct BillingPeriodView: View {
    @Binding var selectedPeriod: String
    @State private var isExpanded = false
    let periods = ["Weekly", "Monthly", "Yearly"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Billing Period")
            VStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedPeriod)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(periods, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                                withAnimation {
                                    isExpanded = false
                                }
                            }) {
                                HStack {
                                    Text(period)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if period == selectedPeriod {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if period != periods.last {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .shadow(radius: 5)
                }
            }
        }
        .padding()
    }
}

// MARK: - Next Payment Date View
struct NextPaymentDateView: View {
    @Binding var nextPaymentDate: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Payment Date")
            DatePicker("", selection: $nextPaymentDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .frame(height: 50)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding()
    }
}
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
