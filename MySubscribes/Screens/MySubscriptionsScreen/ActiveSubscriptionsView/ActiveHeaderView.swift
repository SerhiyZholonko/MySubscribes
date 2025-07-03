
//  AHeader.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

//MARK: - Header
struct SHeader: View {
    let onAddSubscription: () -> Void
    @State private var addButtonPressed = false
    @State private var bellButtonPressed = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Notification Button (Left)
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                // Handle notification action
            }) {
                ZStack {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 44, height: 44)
                        .shadow(
                            color: DesignSystem.Shadows.light,
                            radius: bellButtonPressed ? 2 : 5,
                            x: 0,
                            y: bellButtonPressed ? 1 : 3
                        )
                    
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .scaleEffect(bellButtonPressed ? 1.1 : 1.0)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(bellButtonPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: bellButtonPressed)
            .onLongPressGesture(minimumDuration: 0) {
                bellButtonPressed = true
            } onPressingChanged: { pressing in
                bellButtonPressed = pressing
            }
            
            // Title section (Center)
            VStack(alignment: .leading, spacing: 2) {
                Text("My Subscriptions")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Track your monthly spending")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.accent)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Add Button (Right)
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                onAddSubscription()
            }) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(
                            color: DesignSystem.Colors.primary.opacity(0.3),
                            radius: addButtonPressed ? 3 : 8,
                            x: 0,
                            y: addButtonPressed ? 1 : 4
                        )
                    
                    // Plus icon
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(addButtonPressed ? 1.1 : 1.0)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(addButtonPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: addButtonPressed)
            .onLongPressGesture(minimumDuration: 0) {
                addButtonPressed = true
            } onPressingChanged: { pressing in
                addButtonPressed = pressing
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
}
