//
//  AddSubscriptionView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI
import SwiftData

// MARK: - Simple Button Style
struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Add Subscription View
struct AddSubscriptionView: View {
    @State private var viewModel = AddSubscriptionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Simple Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(SimpleButtonStyle())
                    
                    Spacer()
                    
                    Text("Add Subscription")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Save") {
                        viewModel.saveSubscription()
                    }
                    .buttonStyle(SimpleButtonStyle())
                    .disabled(viewModel.serviceNameText.isEmpty || viewModel.monthlyCostText.isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Service Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Service Name")
                                .font(.headline)
                            
                            TextField("Netflix, Spotify, etc.", text: $viewModel.serviceNameText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Monthly Cost
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Cost")
                                .font(.headline)
                            
                            TextField("9.99", text: $viewModel.monthlyCostText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Simple Billing Period
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Billing Period")
                                .font(.headline)
                            
                            HStack {
                                ForEach(["Weekly", "Monthly", "Yearly"], id: \.self) { period in
                                    Button(action: {
                                        viewModel.selectedPeriod = period
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }) {
                                        Text(period)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                viewModel.selectedPeriod == period ?
                                                Color.blue : Color.gray.opacity(0.2)
                                            )
                                            .foregroundColor(
                                                viewModel.selectedPeriod == period ?
                                                .white : .primary
                                            )
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(SimpleButtonStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Next Payment Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Next Payment Date")
                                .font(.headline)
                            
                            DatePicker("", selection: $viewModel.nextPaymentDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Simple Color Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(["red", "blue", "green", "orange", "purple", "pink", "cyan", "yellow", "brown", "gray"], id: \.self) { color in
                                    Button(action: {
                                        viewModel.selectedColor = color
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }) {
                                        Circle()
                                            .fill(colorForString(color))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: viewModel.selectedColor == color ? 3 : 0)
                                            )
                                            .overlay(
                                                viewModel.selectedColor == color ?
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 16, weight: .bold)) : nil
                                            )
                                    }
                                    .buttonStyle(SimpleButtonStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Simple Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                ForEach(["Entertainment", "Music", "Productivity", "News", "Health", "Other"], id: \.self) { category in
                                    Button(action: {
                                        viewModel.selectedCategory = category
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }) {
                                        Text(category)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                viewModel.selectedCategory == category ?
                                                Color.blue : Color.gray.opacity(0.2)
                                            )
                                            .foregroundColor(
                                                viewModel.selectedCategory == category ?
                                                .white : .primary
                                            )
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(SimpleButtonStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Repetition Settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repetition Settings")
                                .font(.headline)
                            
                            Toggle("Recurring Subscription", isOn: $viewModel.isRecurring)
                                .toggleStyle(SwitchToggleStyle())
                            
                            if viewModel.isRecurring {
                                Toggle("Set End Date", isOn: Binding(
                                    get: { viewModel.endDate != nil },
                                    set: { hasEndDate in
                                        if hasEndDate {
                                            viewModel.endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
                                        } else {
                                            viewModel.endDate = nil
                                        }
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle())
                                
                                if viewModel.endDate != nil {
                                    DatePicker("End Date", selection: Binding(
                                        get: { viewModel.endDate ?? Date() },
                                        set: { viewModel.endDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Reminder Settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminder Settings")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                ForEach([(1, "1 day before"), (3, "3 days before"), (7, "1 week before")], id: \.0) { days, text in
                                    Button(action: {
                                        viewModel.reminderDays = days
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }) {
                                        HStack {
                                            Text(text)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if viewModel.reminderDays == days {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            viewModel.reminderDays == days ?
                                            Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
                                        )
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(SimpleButtonStyle())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Renewal Reminders
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Renewal Reminders")
                                .font(.headline)
                            
                            Toggle("Enable Renewal Reminders", isOn: $viewModel.renewalReminderEnabled)
                                .toggleStyle(SwitchToggleStyle())
                            
                            if viewModel.renewalReminderEnabled && viewModel.endDate != nil {
                                VStack(spacing: 8) {
                                    ForEach([(7, "1 week before expiry"), (30, "1 month before expiry")], id: \.0) { days, text in
                                        Button(action: {
                                            viewModel.renewalReminderDays = days
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                        }) {
                                            HStack {
                                                Text(text)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                if viewModel.renewalReminderDays == days {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding()
                                            .background(
                                                viewModel.renewalReminderDays == days ?
                                                Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
                                            )
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(SimpleButtonStyle())
                                    }
                                }
                            } else if viewModel.renewalReminderEnabled && viewModel.endDate == nil {
                                Text("Set an end date to enable renewal reminders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(Color.yellow.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            
                            TextField("Add any additional notes...", text: $viewModel.notes, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert("Subscription", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    private func colorForString(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "cyan": return .cyan
        case "yellow": return .yellow
        case "brown": return .brown
        case "gray": return .gray
        default: return .blue
        }
    }
}

#Preview {
    AddSubscriptionView()
}