//
//  EnhancedFormComponents.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

// MARK: - Repetition Settings View
struct RepetitionSettingsView: View {
    @Binding var isRecurring: Bool
    @Binding var endDate: Date?
    @State private var hasEndDate = false
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "repeat")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Repetition Settings")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: DesignSystem.Spacing.md) {
                // Recurring Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Recurring Subscription")
                            .font(.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Enable for recurring payments")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isRecurring)
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.accent))
                }
                
                if isRecurring && showContent {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Divider()
                            .opacity(0.5)
                        
                        // End Date Option
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Set End Date")
                                    .font(.body)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Optional expiration date")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $hasEndDate)
                                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
                        }
                        
                        if hasEndDate {
                            DatePicker(
                                "End Date",
                                selection: Binding(
                                    get: { endDate ?? Date() },
                                    set: { endDate = $0 }
                                ),
                                displayedComponents: .date
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .accentColor(DesignSystem.Colors.primary)
                            .transition(.slide)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showContent = true
            }
        }
        .onChange(of: isRecurring) { _, newValue in
            if !newValue {
                hasEndDate = false
                endDate = nil
            }
        }
        .onChange(of: hasEndDate) { _, newValue in
            if !newValue {
                endDate = nil
            } else if endDate == nil {
                endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
            }
        }
    }
}

// MARK: - Category Selection View
struct CategorySelectionView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @State private var showContent = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "folder")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Category")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            if showContent {
                LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                    ForEach(categories, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = category
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
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showContent = true
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(isSelected ? DesignSystem.Colors.primary : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(
                                    isSelected ? Color.clear : DesignSystem.Colors.textTertiary.opacity(0.3),
                                    lineWidth: 1
                                )
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

// MARK: - Color Selection View
struct ColorSelectionView: View {
    @Binding var selectedColor: String
    let colors: [String]
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "paintbrush")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Color Theme")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            if showContent {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(colors, id: \.self) { color in
                        ColorButton(
                            color: color,
                            isSelected: selectedColor == color,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedColor = color
                                }
                            }
                        )
                    }
                    
                    Spacer()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    private var displayColor: Color {
        switch color {
        case "red": return DesignSystem.Colors.netflix
        case "green": return DesignSystem.Colors.spotify
        case "blue": return DesignSystem.Colors.apple
        case "orange": return DesignSystem.Colors.amazon
        case "purple": return DesignSystem.Colors.primary
        default: return DesignSystem.Colors.primary
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(displayColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: isSelected ? 3 : 0)
                    )
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.primary, lineWidth: isSelected ? 2 : 0)
                            .scaleEffect(1.2)
                    )
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
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

// MARK: - Reminder Settings View
struct ReminderSettingsView: View {
    @Binding var reminderDays: Int
    let reminderOptions: [(Int, String)]
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "bell.badge")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Reminder Settings")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            if showContent {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(reminderOptions, id: \.0) { option in
                        ReminderOptionButton(
                            days: option.0,
                            text: option.1,
                            isSelected: reminderDays == option.0,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    reminderDays = option.0
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
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Reminder Option Button
struct ReminderOptionButton: View {
    let days: Int
    let text: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.accent : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.clear : DesignSystem.Colors.textTertiary.opacity(0.3),
                                    lineWidth: 2
                                )
                        )
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                                .opacity(isSelected ? 1 : 0)
                        )
                    
                    Text(text)
                        .font(.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Notes View
struct NotesView: View {
    @Binding var notes: String
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Notes")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            if showContent {
                TextField("Add any additional notes...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(DesignSystem.Colors.textTertiary.opacity(0.1))
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                showContent = true
            }
        }
    }
}
