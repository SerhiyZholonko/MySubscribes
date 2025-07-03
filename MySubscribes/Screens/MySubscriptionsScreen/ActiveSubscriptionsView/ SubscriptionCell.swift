//
//   SubscriptionCell.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct SubscriptionCell: View {
    let subscription: Subscription
    let onDelete: () -> Void
    @StateObject private var viewModel: SubscriptionCellViewModel
    @State private var isPressed = false
    @State private var showDetails = false
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0
    
    init(subscription: Subscription, onDelete: @escaping () -> Void) {
        self.subscription = subscription
        self.onDelete = onDelete
        self._viewModel = StateObject(wrappedValue: SubscriptionCellViewModel(subscription: subscription))
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showDetails.toggle()
            }
        }) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Service Icon with animated background
                    ZStack {
                        // Animated background circles
                        Circle()
                            .fill(viewModel.serviceColor.opacity(0.2))
                            .frame(width: 70, height: 70)
                            .scaleEffect(isPressed ? 1.1 : 1.0)
                        
                        Circle()
                            .fill(viewModel.serviceColor)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: viewModel.serviceIcon)
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .scaleEffect(isPressed ? 1.1 : 1.0)
                    }
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
                    
                    // Service Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscription.serviceName)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.accent)
                            
                            Text("Next: \(viewModel.formattedNextPaymentDate)")
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        // Days until payment with color coding
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(daysUntilColor)
                            
                            Text("\(viewModel.daysUntilPayment) days")
                                .font(.caption)
                                .foregroundColor(daysUntilColor)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    // Cost and Actions
                    VStack(alignment: .trailing, spacing: 8) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("$\(viewModel.formattedCost)")
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(DesignSystem.Colors.primary)
                                .fontWeight(.bold)
                            
                            Text(subscription.billingPeriod.lowercased())
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                                )
                        }
                        
                        // Delete button with animation
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            onDelete()
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(DesignSystem.Colors.error)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 26, height: 26)
                                )
                        }
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                    }
                }
                .padding(DesignSystem.Spacing.md)
                
                // Expandable details section
                if showDetails {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Divider()
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Created")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                Text(subscription.createdDate, style: .date)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Billing Period")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                Text(subscription.billingPeriod)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.sm)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .cardStyle(isPressed: isPressed)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3))) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .onLongPressGesture(minimumDuration: 0) { 
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    private var daysUntilColor: Color {
        switch viewModel.daysUntilPayment {
        case 0...3:
            return DesignSystem.Colors.error
        case 4...7:
            return DesignSystem.Colors.warning
        default:
            return DesignSystem.Colors.success
        }
    }
}


