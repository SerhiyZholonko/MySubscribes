//
//  PaymentCalendarView.swift
//  MySubscribes
//
//  Created by apple on 22.06.2025.
//

import SwiftUI
import SwiftData

struct PaymentCalendarView: View {
    @State private var selectedDate: Date? = nil
    @State private var currentMonth: Date = Date()
    @State private var showingPaymentDetails = false
    @State private var selectedPayments: [Subscription] = []
    @State private var showContent = false
    @State private var viewMode: CalendarViewMode = .month
    @Query private var subscriptions: [Subscription]
    
    private let calendar = Calendar.current
    
    var body: some View {
        // Minimal debug logging
        let _ = print("📊 Found \(subscriptions.count) subscription(s)")
        
        ZStack {
            // Background
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced Header
                CalendarHeaderView(
                    currentMonth: $currentMonth,
                    viewMode: $viewMode,
                    onPreviousMonth: { changeMonth(by: -1) },
                    onNextMonth: { changeMonth(by: 1) }
                )
                .opacity(showContent ? 1.0 : 0)
                .offset(y: showContent ? 0 : -30)
                
                // Calendar Content
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Calendar Grid
                        CalendarGridView(
                            currentMonth: currentMonth,
                            selectedDate: $selectedDate,
                            subscriptions: subscriptions,
                            onDateSelected: { date, payments in
                                selectedDate = date
                                selectedPayments = payments
                                if !payments.isEmpty {
                                    showingPaymentDetails = true
                                }
                            }
                        )
                        .opacity(showContent ? 1.0 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Payment Summary
                        PaymentSummaryView(
                            currentMonth: currentMonth,
                            subscriptions: subscriptions
                        )
                        .opacity(showContent ? 1.0 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Upcoming Payments
                        UpcomingPaymentsView(subscriptions: subscriptions)
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Calendar Legend
                        PaymentCalendarLegendView(subscriptions: subscriptions)
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showingPaymentDetails) {
            PaymentDetailsSheet(
                date: selectedDate ?? Date(),
                payments: selectedPayments
            )
        }
    }
    
    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
                currentMonth = newDate
            }
        }
    }
}

// MARK: - Calendar View Mode
enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    
    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        }
    }
}

// MARK: - Calendar Header View
struct CalendarHeaderView: View {
    @Binding var currentMonth: Date
    @Binding var viewMode: CalendarViewMode
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Title and Navigation
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment Calendar")
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Track your subscription payments")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
            
            // Month Navigation
            HStack {
                Button(action: onPreviousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.regularMaterial)
                                .shadow(color: DesignSystem.Shadows.light, radius: 4, x: 0, y: 2)
                        )
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(monthFormatter.string(from: currentMonth))
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(isCurrentMonth ? "This Month" : "")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                
                Spacer()
                
                Button(action: onNextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.regularMaterial)
                                .shadow(color: DesignSystem.Shadows.light, radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date?
    let subscriptions: [Subscription]
    let onDateSelected: (Date, [Subscription]) -> Void
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Days of week header
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if date == Date.distantPast {
                        // Empty cell for padding
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 50)
                    } else {
                        CalendarDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            payments: paymentsForDate(date),
                            onTap: {
                                let payments = paymentsForDate(date)
                                onDateSelected(date, payments)
                            }
                        )
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var daysInMonth: [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        var days: [Date] = []
        
        // Add empty days for the beginning of the month
        for _ in 1..<firstWeekday {
            days.append(Date.distantPast)
        }
        
        // Add actual days of the month
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func paymentsForDate(_ date: Date) -> [Subscription] {
        return subscriptions.compactMap { subscription -> Subscription? in
            if hasPaymentOnDate(subscription: subscription, date: date) {
                return subscription
            }
            return nil
        }
    }
    
    // Check if subscription has payment on specific date (including recurring payments)
    private func hasPaymentOnDate(subscription: Subscription, date: Date) -> Bool {
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
        return isRecurringPaymentDate(subscription: subscription, targetDate: date)
    }
    
    private func isRecurringPaymentDate(subscription: Subscription, targetDate: Date) -> Bool {
        let startDate = subscription.nextPaymentDate
        
        // Calculate days between start date and target date
        let daysBetween = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
        
        // Check if target date matches billing period
        switch subscription.billingPeriod {
        case "Weekly":
            return daysBetween >= 0 && daysBetween % 7 == 0
        case "Monthly":
            // For monthly, we need to check if it's a valid monthly interval
            let monthComponents = calendar.dateComponents([.month, .day], from: startDate, to: targetDate)
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
        switch period {
        case "Weekly":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case "Monthly":
            return calendar.date(byAdding: .month, value: 1, to: date)
        case "Quarterly":
            return calendar.date(byAdding: .month, value: 3, to: date)
        case "Yearly":
            return calendar.date(byAdding: .year, value: 1, to: date)
        default:
            return calendar.date(byAdding: .month, value: 1, to: date)
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let payments: [Subscription]
    let onTap: () -> Void
    
    @State private var isPressed = false
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Base card background
                RoundedRectangle(cornerRadius: 8)
                    .fill(dayBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(dayBorderColor, lineWidth: dayBorderWidth)
                    )
                
                VStack(spacing: 2) {
                    // Day number with enhanced styling
                    Text(dayNumber)
                        .font(.system(size: dayNumberFontSize, weight: dayTextWeight))
                        .foregroundColor(dayTextColor)
                    
                    // Enhanced payment indicators
                    if !payments.isEmpty {
                        PaymentIndicatorsView(payments: payments)
                    }
                    
                    // Enhanced amount indicator
                    if !payments.isEmpty {
                        Text(String(format: "$%.0f", totalAmount))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(amountTextColor)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                Capsule()
                                    .fill(amountBackgroundColor)
                            )
                    }
                }
                
                // Special indicators for different states
                if hasHighPriorityPayments {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(DesignSystem.Colors.error)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            .frame(width: 45, height: 50)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) { 
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
    
    private var totalAmount: Double {
        payments.reduce(0) { $0 + $1.monthlyCost }
    }
    
    // Enhanced styling computed properties
    private var dayBackgroundColor: Color {
        if isSelected {
            return DesignSystem.Colors.primary.opacity(0.2)
        } else if isToday {
            return DesignSystem.Colors.primary.opacity(0.1)
        } else if !payments.isEmpty {
            return paymentBackgroundColor
        } else {
            return Color.clear
        }
    }
    
    private var paymentBackgroundColor: Color {
        let totalPayments = payments.count
        if totalPayments >= 3 {
            return DesignSystem.Colors.error.opacity(0.1)
        } else if totalPayments >= 2 {
            return DesignSystem.Colors.warning.opacity(0.1)
        } else {
            return DesignSystem.Colors.success.opacity(0.1)
        }
    }
    
    private var dayBorderColor: Color {
        if isSelected {
            return DesignSystem.Colors.primary
        } else if isToday && !isSelected {
            return DesignSystem.Colors.primary.opacity(0.7)
        } else if !payments.isEmpty {
            return paymentBorderColor
        } else {
            return Color.clear
        }
    }
    
    private var paymentBorderColor: Color {
        let totalPayments = payments.count
        if totalPayments >= 3 {
            return DesignSystem.Colors.error.opacity(0.3)
        } else if totalPayments >= 2 {
            return DesignSystem.Colors.warning.opacity(0.3)
        } else {
            return DesignSystem.Colors.success.opacity(0.3)
        }
    }
    
    private var dayBorderWidth: CGFloat {
        if isSelected || isToday || !payments.isEmpty {
            return 1.5
        } else {
            return 0
        }
    }
    
    private var dayTextColor: Color {
        if isSelected {
            return DesignSystem.Colors.primary
        } else if isToday {
            return DesignSystem.Colors.primary
        } else if !payments.isEmpty {
            return DesignSystem.Colors.textPrimary
        } else if isCurrentMonth {
            return DesignSystem.Colors.textPrimary
        } else {
            return DesignSystem.Colors.textTertiary
        }
    }
    
    private var dayTextWeight: Font.Weight {
        if isSelected || isToday || !payments.isEmpty {
            return .bold
        } else {
            return .medium
        }
    }
    
    private var dayNumberFontSize: CGFloat {
        if !payments.isEmpty {
            return 14
        } else {
            return 16
        }
    }
    
    private var amountTextColor: Color {
        if !payments.isEmpty {
            let totalPayments = payments.count
            if totalPayments >= 3 {
                return DesignSystem.Colors.error
            } else if totalPayments >= 2 {
                return DesignSystem.Colors.warning
            } else {
                return DesignSystem.Colors.success
            }
        }
        return DesignSystem.Colors.textSecondary
    }
    
    private var amountBackgroundColor: Color {
        if !payments.isEmpty {
            let totalPayments = payments.count
            if totalPayments >= 3 {
                return DesignSystem.Colors.error.opacity(0.15)
            } else if totalPayments >= 2 {
                return DesignSystem.Colors.warning.opacity(0.15)
            } else {
                return DesignSystem.Colors.success.opacity(0.15)
            }
        }
        return Color.clear
    }
    
    private var hasHighPriorityPayments: Bool {
        return payments.contains { payment in
            payment.monthlyCost >= 50.0 // High-value payments
        }
    }
}

// MARK: - Payment Indicators View
struct PaymentIndicatorsView: View {
    let payments: [Subscription]
    
    var body: some View {
        HStack(spacing: 1) {
            if payments.count == 1 {
                // Single payment - show larger indicator with billing period color
                RoundedRectangle(cornerRadius: 2)
                    .fill(DesignSystem.Colors.colorForBillingPeriod(payments.first?.billingPeriod ?? "Monthly"))
                    .frame(width: 16, height: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(DesignSystem.Colors.colorForBillingPeriod(payments.first?.billingPeriod ?? "Monthly").opacity(0.3), lineWidth: 0.5)
                    )
            } else if payments.count == 2 {
                // Two payments - show two bars with period colors
                ForEach(Array(payments.enumerated()), id: \.offset) { index, payment in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.colorForBillingPeriod(payment.billingPeriod),
                                    payment.displayColor
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 7, height: 3)
                }
            } else if payments.count == 3 {
                // Three payments - show three dots with mixed colors
                ForEach(Array(payments.enumerated()), id: \.offset) { index, payment in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.colorForBillingPeriod(payment.billingPeriod),
                                    payment.displayColor
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 2
                            )
                        )
                        .frame(width: 4, height: 4)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                }
            } else {
                // Multiple payments - show dots with counter
                HStack(spacing: 1) {
                    ForEach(Array(payments.prefix(2).enumerated()), id: \.offset) { index, payment in
                        Circle()
                            .fill(DesignSystem.Colors.colorForBillingPeriod(payment.billingPeriod))
                            .frame(width: 3, height: 3)
                    }
                    
                    Text("+\(payments.count - 2)")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(.horizontal, 2)
                        .background(
                            Capsule()
                                .fill(DesignSystem.Colors.backgroundSecondary)
                        )
                }
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    PaymentCalendarView()
}
