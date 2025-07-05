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
        return subscriptions.filter { subscription in
            calendar.isDate(subscription.nextPaymentDate, inSameDayAs: date)
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
            VStack(spacing: 4) {
                // Day number
                Text(dayNumber)
                    .font(.system(size: 16, weight: isSelected || isToday ? .bold : .medium))
                    .foregroundColor(
                        isSelected ? DesignSystem.Colors.textPrimary :
                        isToday ? DesignSystem.Colors.primary :
                        isCurrentMonth ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary
                    )
                
                // Payment indicators
                HStack(spacing: 2) {
                    ForEach(Array(payments.prefix(3).enumerated()), id: \.offset) { index, payment in
                        Circle()
                            .fill(payment.displayColor)
                            .frame(width: 6, height: 6)
                    }
                    
                    if payments.count > 3 {
                        Text("+")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .frame(height: 8)
                
                // Amount indicator
                if !payments.isEmpty {
                    Text(String(format: "$%.0f", totalAmount))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary.opacity(0.8) : DesignSystem.Colors.textSecondary)
                }
            }
            .frame(width: 45, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected ? DesignSystem.Colors.primary.opacity(0.15) :
                        isToday ? DesignSystem.Colors.primary.opacity(0.1) :
                        !payments.isEmpty ? DesignSystem.Colors.accent.opacity(0.05) :
                        Color.clear
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? DesignSystem.Colors.primary :
                        isToday && !isSelected ? DesignSystem.Colors.primary : 
                        Color.clear,
                        lineWidth: isSelected ? 2 : 2
                    )
            )
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
}

#Preview {
    PaymentCalendarView()
}
