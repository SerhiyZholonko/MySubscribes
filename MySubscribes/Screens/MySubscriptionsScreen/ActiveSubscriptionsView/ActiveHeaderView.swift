
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
        VStack(spacing: 8) {
            // Top row: Logo and Title
            HStack(spacing: 12) {
                AppLogo(size: 40, showText: false)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Subscriptions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Track your monthly spending")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Bottom row: Notification and Add buttons
            HStack {
                // Notification Button (Left)
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    // Handle notification action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text("Notifications")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(DesignSystem.Colors.textSecondary.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .scaleEffect(bellButtonPressed ? 0.95 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.easeInOut(duration: 0.1), value: bellButtonPressed)
                .onLongPressGesture(minimumDuration: 0) {
                    bellButtonPressed = true
                } onPressingChanged: { pressing in
                    bellButtonPressed = pressing
                }
                
                Spacer()
                
                // Add Button (Right)
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onAddSubscription()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Add Subscription")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(DesignSystem.Colors.primary.opacity(0.6), lineWidth: 1.5)
                            )
                    )
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
                        radius: addButtonPressed ? 3 : 8,
                        x: 0,
                        y: addButtonPressed ? 1 : 4
                    )
                    .scaleEffect(addButtonPressed ? 0.95 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.easeInOut(duration: 0.1), value: addButtonPressed)
                .onLongPressGesture(minimumDuration: 0) {
                    addButtonPressed = true
                } onPressingChanged: { pressing in
                    addButtonPressed = pressing
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
}
