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
    
    private var monthlyPayments: [(Subscription, [Date])] {
        let calendar = Calendar.current
        var paymentsBySubscription: [String: (Subscription, [Date])] = [:]
        
        // Get all days in the current month
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        // Check each day of the month for payments
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                let paymentsOnDate = getPaymentsForDate(date)
                for payment in paymentsOnDate {
                    let key = payment.serviceName + "_" + payment.billingPeriod
                    if var existing = paymentsBySubscription[key] {
                        existing.1.append(date)
                        paymentsBySubscription[key] = existing
                    } else {
                        paymentsBySubscription[key] = (payment, [date])
                    }
                }
            }
        }
        
        return Array(paymentsBySubscription.values)
    }
    
    // Helper function to get payments for a specific date (including recurring)
    private func getPaymentsForDate(_ date: Date) -> [Subscription] {
        return subscriptions.compactMap { subscription -> Subscription? in
            if hasPaymentOnDate(subscription: subscription, date: date) {
                return subscription
            }
            return nil
        }
    }
    
    // Check if subscription has payment on specific date (including recurring payments)
    private func hasPaymentOnDate(subscription: Subscription, date: Date) -> Bool {
        let calendar = Calendar.current
        
        // First check: is this the exact next payment date?
        if calendar.isDate(subscription.nextPaymentDate, inSameDayAs: date) {
            return true
        }
        
        // If not recurring, only check the next payment date
        guard subscription.isRecurring else {
            return false
        }
        
        // Check if date is before the first payment
        if date < subscription.nextPaymentDate {
            return false
        }
        
        // Check if date is after end date (if exists)
        if let endDate = subscription.endDate, date > endDate {
            return false
        }
        
        // For recurring subscriptions, calculate if this date matches the billing cycle
        return isRecurringPaymentDate(subscription: subscription, targetDate: date, calendar: calendar)
    }
    
    private func isRecurringPaymentDate(subscription: Subscription, targetDate: Date, calendar: Calendar) -> Bool {
        let startDate = subscription.nextPaymentDate
        
        // Check if target date matches billing period
        switch subscription.billingPeriod {
        case "Weekly":
            let daysBetween = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
            return daysBetween >= 0 && daysBetween % 7 == 0
        case "Monthly":
            // For monthly, check if it's the same day of different months
            let monthComponents = calendar.dateComponents([.month], from: startDate, to: targetDate)
            let monthsFromStart = monthComponents.month ?? 0
            let dayOfMonth = calendar.component(.day, from: startDate)
            let targetDayOfMonth = calendar.component(.day, from: targetDate)
            
            return monthsFromStart >= 0 && dayOfMonth == targetDayOfMonth
        case "Quarterly":
            // Check if it's a 3-month interval
            let monthComponents = calendar.dateComponents([.month], from: startDate, to: targetDate)
            let monthsFromStart = monthComponents.month ?? 0
            let dayOfMonth = calendar.component(.day, from: startDate)
            let targetDayOfMonth = calendar.component(.day, from: targetDate)
            
            return monthsFromStart >= 0 && monthsFromStart % 3 == 0 && dayOfMonth == targetDayOfMonth
        case "Yearly":
            // Check if it's a yearly interval on the same date
            let components = calendar.dateComponents([.year, .month, .day], from: startDate, to: targetDate)
            let yearsFromStart = components.year ?? 0
            let monthsFromStart = components.month ?? 0
            let daysFromStart = components.day ?? 0
            
            return yearsFromStart >= 0 && monthsFromStart == 0 && daysFromStart == 0
        default:
            return false
        }
    }
    
    // Get all payment dates for subscription up to a specific date (within 2 years for performance)
    private func getAllPaymentDates(for subscription: Subscription, upToDate: Date) -> [Date] {
        var paymentDates: [Date] = []
        var currentDate = subscription.nextPaymentDate
        let calendar = Calendar.current
        
        // Limit to 2 years from first payment date for performance
        let maxDate = min(upToDate, calendar.date(byAdding: .year, value: 2, to: subscription.nextPaymentDate) ?? upToDate)
        
        while currentDate <= maxDate {
            paymentDates.append(currentDate)
            
            // Calculate next payment date based on billing period
            guard let nextDate = getNextPaymentDate(from: currentDate, period: subscription.billingPeriod) else {
                break
            }
            
            // Check if we've passed the end date
            if let endDate = subscription.endDate, nextDate > endDate {
                break
            }
            
            currentDate = nextDate
        }
        
        return paymentDates
    }
    
    // Helper function to get next payment date based on billing period
    private func getNextPaymentDate(from date: Date, period: String) -> Date? {
        let calendar = Calendar.current
        // Normalize input date to start of day to avoid timezone issues
        let normalizedDate = calendar.startOfDay(for: date)
        
        switch period {
        case "Weekly":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: normalizedDate)
        case "Monthly":
            return calendar.date(byAdding: .month, value: 1, to: normalizedDate)
        case "Quarterly":
            return calendar.date(byAdding: .month, value: 3, to: normalizedDate)
        case "Yearly":
            return calendar.date(byAdding: .year, value: 1, to: normalizedDate)
        default:
            return calendar.date(byAdding: .month, value: 1, to: normalizedDate)
        }
    }
    
    private var totalAmount: Double {
        monthlyPayments.reduce(0) { total, paymentInfo in
            let (subscription, dates) = paymentInfo
            return total + (subscription.monthlyCost * Double(dates.count))
        }
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
                    value: "\(monthlyPayments.reduce(0) { $0 + $1.1.count })",
                    color: DesignSystem.Colors.accent,
                    icon: "calendar.badge.clock"
                )
                
                SummaryStatView(
                    title: "Services",
                    value: "\(monthlyPayments.count)",
                    color: DesignSystem.Colors.success,
                    icon: "folder.fill"
                )
            }
            
            if showDetails && !monthlyPayments.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Divider()
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    
                    ForEach(Array(monthlyPayments.prefix(5).enumerated()), id: \.offset) { index, paymentInfo in
                        let (subscription, dates) = paymentInfo
                        PaymentSummaryRowWithDates(subscription: subscription, dates: dates)
                    }
                    
                    if monthlyPayments.count > 5 {
                        Text("+ \(monthlyPayments.count - 5) more services")
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

// MARK: - Payment Summary Row With Dates
struct PaymentSummaryRowWithDates: View {
    let subscription: Subscription
    let dates: [Date]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    private var totalAmount: Double {
        subscription.monthlyCost * Double(dates.count)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(subscription.displayColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.serviceName)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if dates.count > 1 {
                    Text("\(dates.count) payments this month")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", totalAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if let firstDate = dates.first {
                    Text(dates.count == 1 ? dateFormatter.string(from: firstDate) : "Multiple dates")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
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
    
    private var billingPeriods: [(String, Color, String)] {
        let periods = Array(Set(subscriptions.map { $0.billingPeriod }))
        return periods.map { period in
            let icon: String
            switch period {
            case "Weekly": icon = "calendar.day.timeline.left"
            case "Monthly": icon = "calendar"
            case "Quarterly": icon = "calendar.badge.plus"
            case "Yearly": icon = "calendar.badge.clock"
            default: icon = "calendar"
            }
            return (period, DesignSystem.Colors.colorForBillingPeriod(period), icon)
        }.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Billing Periods Legend
            if !billingPeriods.isEmpty {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Header
                    HStack {
                        Image(systemName: "paintbrush")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.accent)
                        
                        Text("Billing Periods")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    // Billing period items
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                        ForEach(Array(billingPeriods.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                // Period indicator
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(item.1)
                                    .frame(width: 16, height: 3)
                                
                                Image(systemName: item.2)
                                    .font(.caption)
                                    .foregroundColor(item.1)
                                
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
            
            // Categories Legend
            if !uniqueCategories.isEmpty {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Header
                    HStack {
                        Image(systemName: "folder.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text("Service Categories")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    // Category items
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                        ForEach(Array(uniqueCategories.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Circle()
                                    .fill(item.1)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                
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
            
            // Payment Intensity Legend
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("Payment Intensity")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                }
                
                // Intensity items
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Circle()
                            .fill(DesignSystem.Colors.success)
                            .frame(width: 8, height: 8)
                        
                        Text("Single Payment")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Circle()
                            .fill(DesignSystem.Colors.warning)
                            .frame(width: 8, height: 8)
                        
                        Text("2 Payments")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Circle()
                            .fill(DesignSystem.Colors.error)
                            .frame(width: 8, height: 8)
                        
                        Text("3+ Payments")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Circle()
                            .fill(DesignSystem.Colors.error)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        
                        Text("High Value Payment ($50+)")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
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
