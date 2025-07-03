//
//  CalendarComponents.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI
import SwiftData

// MARK: - Payment Summary View
struct PaymentSummaryView: View {
    let currentMonth: Date
    let subscriptions: [Subscription]
    @State private var showDetails = false
    
    private var monthlyPayments: [Subscription] {
        let calendar = Calendar.current
        return subscriptions.filter { subscription in
            calendar.isDate(subscription.nextPaymentDate, equalTo: currentMonth, toGranularity: .month)
        }
    }
    
    private var totalAmount: Double {
        monthlyPayments.reduce(0) { $0 + $1.monthlyCost }
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("\(monthFormatter.string(from: currentMonth)) Summary")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Button(action: { showDetails.toggle() }) {
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            // Summary Stats
            HStack(spacing: DesignSystem.Spacing.lg) {
                SummaryStatView(
                    title: "Total",
                    value: String(format: "$%.2f", totalAmount),
                    color: DesignSystem.Colors.primary,
                    icon: "dollarsign.circle.fill"
                )
                
                SummaryStatView(
                    title: "Payments",
                    value: "\(monthlyPayments.count)",
                    color: DesignSystem.Colors.accent,
                    icon: "calendar.badge.clock"
                )
                
                SummaryStatView(
                    title: "Services",
                    value: "\(Set(monthlyPayments.map { $0.category }).count)",
                    color: DesignSystem.Colors.success,
                    icon: "folder.fill"
                )
            }
            
            if showDetails && !monthlyPayments.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Divider()
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    
                    ForEach(monthlyPayments.prefix(5), id: \.id) { payment in
                        PaymentSummaryRow(payment: payment)
                    }
                    
                    if monthlyPayments.count > 5 {
                        Text("+ \(monthlyPayments.count - 5) more payments")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .padding(.top, DesignSystem.Spacing.sm)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .cardStyle()
    }
}

// MARK: - Summary Stat View
struct SummaryStatView: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Payment Summary Row
struct PaymentSummaryRow: View {
    let payment: Subscription
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(payment.displayColor)
                .frame(width: 8, height: 8)
            
            Text(payment.serviceName)
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", payment.monthlyCost))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(dateFormatter.string(from: payment.nextPaymentDate))
                    .font(.caption2)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Upcoming Payments View
struct UpcomingPaymentsView: View {
    let subscriptions: [Subscription]
    
    private var upcomingPayments: [Subscription] {
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        
        return subscriptions
            .filter { subscription in
                subscription.nextPaymentDate >= Date() && subscription.nextPaymentDate <= nextWeek
            }
            .sorted { $0.nextPaymentDate < $1.nextPaymentDate }
    }
    
    var body: some View {
        if !upcomingPayments.isEmpty {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                HStack {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.warning)
                    
                    Text("Upcoming This Week")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                }
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(upcomingPayments.prefix(3), id: \.id) { payment in
                        UpcomingPaymentRow(payment: payment)
                    }
                }
            }
            .cardStyle()
        }
    }
}

// MARK: - Upcoming Payment Row
struct UpcomingPaymentRow: View {
    let payment: Subscription
    @State private var isPressed = false
    
    private var daysUntil: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: payment.nextPaymentDate)
        return max(0, components.day ?? 0)
    }
    
    private var urgencyColor: Color {
        switch daysUntil {
        case 0: return DesignSystem.Colors.error
        case 1...2: return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.success
        }
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Service indicator
            ZStack {
                Circle()
                    .fill(payment.displayColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Circle()
                    .fill(payment.displayColor)
                    .frame(width: 32, height: 32)
                
                Text(String(payment.serviceName.prefix(1)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Payment info
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.serviceName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(payment.category)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Days and amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", payment.monthlyCost))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(urgencyColor)
                        .frame(width: 6, height: 6)
                    
                    Text(daysUntil == 0 ? "Today" : "\(daysUntil) day\(daysUntil == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(urgencyColor)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // Could add navigation to payment details
        }
        .onLongPressGesture(minimumDuration: 0) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Payment Calendar Legend View
struct PaymentCalendarLegendView: View {
    let subscriptions: [Subscription]
    
    private var uniqueCategories: [(String, Color)] {
        let categories = Array(Set(subscriptions.map { $0.category }))
        return categories.map { category in
            let subscription = subscriptions.first { $0.category == category }
            return (category, subscription?.displayColor ?? DesignSystem.Colors.primary)
        }.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        if !uniqueCategories.isEmpty {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Categories")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                }
                
                // Legend items
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                    ForEach(Array(uniqueCategories.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Circle()
                                .fill(item.1)
                                .frame(width: 12, height: 12)
                            
                            Text(item.0)
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                        }
                    }
                }
            }
            .cardStyle()
        }
    }
}

// MARK: - Payment Details Sheet
struct PaymentDetailsSheet: View {
    let date: Date
    let payments: [Subscription]
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
    
    private var totalAmount: Double {
        payments.reduce(0) { $0 + $1.monthlyCost }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Date header
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text(dateFormatter.string(from: date))
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text(String(format: "Total: $%.2f", totalAmount))
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        .cardStyle()
                        
                        // Payments list
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(payments, id: \.id) { payment in
                                PaymentDetailRow(payment: payment)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}

// MARK: - Payment Detail Row
struct PaymentDetailRow: View {
    let payment: Subscription
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Service icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(payment.displayColor)
                    .frame(width: 50, height: 50)
                
                Text(String(payment.serviceName.prefix(2)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Service details
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.serviceName)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(payment.category)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("Billing: \(payment.billingPeriod)")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
            
            // Amount
            Text(String(format: "$%.2f", payment.monthlyCost))
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .cardStyle()
    }
}
