//
//  EnhancedCalendarView.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

// MARK: - Enhanced Calendar View
struct EnhancedCalendarView: View {
    @Binding var selectedDate: Date
    let subscriptions: [Subscription]
    @State private var showContent = false
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Payment Date")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            if showContent {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Month Navigation
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        Spacer()
                        
                        Text(dateFormatter.string(from: currentMonth))
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    
                    // Calendar Grid
                    EnhancedCalendarGridView(
                        selectedDate: $selectedDate,
                        currentMonth: currentMonth,
                        subscriptions: subscriptions
                    )
                    
                    // Legend
                    if !subscriptions.isEmpty {
                        CalendarLegendView(subscriptions: subscriptions)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

// MARK: - Enhanced Calendar Grid View
struct EnhancedCalendarGridView: View {
    @Binding var selectedDate: Date
    let currentMonth: Date
    let subscriptions: [Subscription]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var daysInMonth: [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date] = []
        
        // Add empty days for the beginning of the month
        for _ in 1..<firstWeekday {
            days.append(Date.distantPast)
        }
        
        // Add actual days of the month
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: DesignSystem.Spacing.xs) {
                ForEach(daysInMonth, id: \.self) { date in
                    if date == Date.distantPast {
                        // Empty cell
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                    } else {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            subscriptions: subscriptionsForDate(date),
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    private func subscriptionsForDate(_ date: Date) -> [Subscription] {
        return subscriptions.filter { subscription in
            calendar.isDate(subscription.nextPaymentDate, inSameDayAs: date)
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let subscriptions: [Subscription]
    let onTap: () -> Void
    
    @State private var isPressed = false
    private let calendar = Calendar.current
    
    private var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Day number
                Text(dayNumber)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? DesignSystem.Colors.primary :
                        DesignSystem.Colors.textPrimary
                    )
                
                // Subscription indicators
                HStack(spacing: 2) {
                    ForEach(Array(subscriptions.prefix(3).enumerated()), id: \.offset) { index, subscription in
                        Circle()
                            .fill(subscription.displayColor)
                            .frame(width: 4, height: 4)
                    }
                    
                    if subscriptions.count > 3 {
                        Text("+")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .frame(height: 8)
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(
                        isSelected ? DesignSystem.Colors.primary :
                        isToday ? DesignSystem.Colors.primary.opacity(0.1) :
                        Color.clear
                    )
            )
            .overlay(
                Circle()
                    .stroke(
                        isToday && !isSelected ? DesignSystem.Colors.primary : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Calendar Legend View
struct CalendarLegendView: View {
    let subscriptions: [Subscription]
    
    private var uniqueColors: [Color] {
        let colors = subscriptions.map { $0.displayColor }
        return Array(Set(colors.map { $0.description }))
            .compactMap { colorString in
                subscriptions.first { $0.displayColor.description == colorString }?.displayColor
            }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Legend")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.xs) {
                ForEach(Array(uniqueColors.enumerated()), id: \.offset) { index, color in
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                        
                        Text(categoryForColor(color))
                            .font(.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }
    
    private func categoryForColor(_ color: Color) -> String {
        guard let subscription = subscriptions.first(where: { $0.displayColor.description == color.description }) else {
            return "General"
        }
        return subscription.category
    }
}
