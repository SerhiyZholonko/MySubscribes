//
//  SubscriptionCell.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct SubscriptionCell: View {
    let subscription: Subscription
    let onDelete: () -> Void
    let onMarkPaid: () -> Void
    let onEdit: () -> Void
    @State private var viewModel: SubscriptionCellViewModel
    @State private var isPressed = false
    @State private var showDetails = false
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0
    @State private var showPaymentAlert = false
    
    init(subscription: Subscription, onDelete: @escaping () -> Void, onMarkPaid: @escaping () -> Void, onEdit: @escaping () -> Void) {
        self.subscription = subscription
        self.onDelete = onDelete
        self.onMarkPaid = onMarkPaid
        self.onEdit = onEdit
        self._viewModel = State(initialValue: SubscriptionCellViewModel(subscription: subscription))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main subscription view content
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
                        
                        // Payment status
                        HStack(spacing: 4) {
                            Image(systemName: subscription.paymentStatus.icon)
                                .font(.caption)
                                .foregroundColor(subscription.paymentStatus.color)
                            
                            Text(subscription.paymentStatus.rawValue)
                                .font(.caption)
                                .foregroundColor(subscription.paymentStatus.color)
                                .fontWeight(.medium)
                        }
                        
                        // Days until payment (only if not paid)
                        if !subscription.isCurrentPaymentPaid {
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
                    }
                    
                    Spacer()
                    
                    // Cost Information
                    VStack(alignment: .trailing, spacing: 4) {
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
                        
                        // Context menu indicator (subtle)
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary.opacity(0.5))
                            .padding(.top, 4)
                    }
            }
            .padding(DesignSystem.Spacing.md)
            
            // Expandable details section
            if showDetails {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Divider()
                        .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
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
                        
                        // Payment Status Details
                        if subscription.isCurrentPaymentPaid, let lastPaymentDate = subscription.lastPaymentDate {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Last Payment")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                    Text(lastPaymentDate, style: .date)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(DesignSystem.Colors.success)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Payment History")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                    Text("\(subscription.paymentHistory.count) payments")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
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
        .cardStyle(isPressed: isPressed)
        .scaleEffect(scale)
        .opacity(opacity)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showDetails.toggle()
            }
        }
        .contextMenu {
            // Mark as Paid option (only if not already paid)
            if !subscription.isCurrentPaymentPaid {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    showPaymentAlert = true
                }) {
                    Label("Mark as Paid", systemImage: "checkmark.circle.fill")
                }
            }
            
            // Edit option
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                onEdit()
            }) {
                Label("Edit Subscription", systemImage: "pencil")
            }
            
            Divider()
            
            // Delete option
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                onDelete()
            }) {
                Label("Delete Subscription", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3))) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .alert("Mark Payment as Paid?", isPresented: $showPaymentAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Mark as Paid", role: .none) {
                onMarkPaid()
            }
        } message: {
            Text("This will mark the payment of $\(String(format: "%.2f", subscription.monthlyCost)) for \(subscription.serviceName) as paid and update the next payment date.")
        }
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

#Preview {
    SubscriptionCell(
        subscription: Subscription(
            serviceName: "Netflix",
            monthlyCost: 15.99,
            billingPeriod: "Monthly",
            nextPaymentDate: Date()
        ),
        onDelete: {},
        onMarkPaid: {},
        onEdit: {}
    )
}