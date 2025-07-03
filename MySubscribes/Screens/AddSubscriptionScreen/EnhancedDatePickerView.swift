//
//  EnhancedDatePickerView.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

// MARK: - Enhanced Date Picker View
struct EnhancedDatePickerView: View {
    @Binding var nextPaymentDate: Date
    @State private var showContent = false
    @State private var isCompactStyle = true
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Payment Date")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                // Date Style Toggle
                Button(action: toggleDateStyle) {
                    Image(systemName: isCompactStyle ? "calendar" : "list.bullet")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            if showContent {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Selected Date Display
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selected Date")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text(dateFormatter.string(from: nextPaymentDate))
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        Spacer()
                        
                        // Days from now
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Days from now")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text("\(daysFromNow)")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(daysFromNow < 0 ? DesignSystem.Colors.error : DesignSystem.Colors.success)
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(DesignSystem.Colors.primary.opacity(0.05))
                    )
                    
                    // Date Picker
                    Group {
                        if isCompactStyle {
                            DatePicker(
                                "Payment Date",
                                selection: $nextPaymentDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        } else {
                            DatePicker(
                                "Payment Date",
                                selection: $nextPaymentDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }
                    }
                    .accentColor(DesignSystem.Colors.primary)
                    .animation(.easeInOut(duration: 0.3), value: isCompactStyle)
                    
                    // Quick Date Options
                    QuickDateOptionsView(nextPaymentDate: $nextPaymentDate)
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
    
    private var daysFromNow: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextPaymentDate)
        return components.day ?? 0
    }
    
    private func toggleDateStyle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isCompactStyle.toggle()
        }
    }
}

// MARK: - Quick Date Options View
struct QuickDateOptionsView: View {
    @Binding var nextPaymentDate: Date
    @State private var showOptions = false
    
    private let quickOptions = [
        ("Today", 0),
        ("Tomorrow", 1),
        ("Next Week", 7),
        ("Next Month", 30)
    ]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Toggle Button
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showOptions.toggle()
                }
            }) {
                HStack {
                    Text("Quick Options")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: showOptions ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .rotationEffect(.degrees(showOptions ? 180 : 0))
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showOptions {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                    ForEach(quickOptions, id: \.0) { option in
                        QuickDateButton(
                            title: option.0,
                            days: option.1,
                            action: {
                                let calendar = Calendar.current
                                if let newDate = calendar.date(byAdding: .day, value: option.1, to: Date()) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        nextPaymentDate = newDate
                                    }
                                }
                            }
                        )
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Quick Date Button
struct QuickDateButton: View {
    let title: String
    let days: Int
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if days > 0 {
                    Text("+\(days) days")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(DesignSystem.Colors.textTertiary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
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
}

