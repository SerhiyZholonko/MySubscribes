//
//  MySubscriptionsView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI
import SwiftData


// MARK: - Views
struct MySubscriptionsView: View {
    @Binding var showingAddSubscription: Bool
    @State private var viewModel = SubscriptionsViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]
    @State private var headerOffset: CGFloat = -50
    @State private var contentOpacity: Double = 0
    @State private var showingEditSubscription = false
    @State private var subscriptionToEdit: Subscription?
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with animation
                SHeader(onAddSubscription: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingAddSubscription = true
                    }
                })
                .offset(y: headerOffset)
                .opacity(contentOpacity)
                
                // Total spending view
                STotalMonthlySpendingView(viewModel: viewModel)
                    .opacity(contentOpacity)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                
                // Content
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        if viewModel.filteredSubscriptions.isEmpty {
                            if viewModel.subscriptions.isEmpty {
                                EmptyStateView()
                                    .opacity(contentOpacity)
                            } else {
                                EmptyPeriodStateView(period: viewModel.selectedPeriod.rawValue)
                                    .opacity(contentOpacity)
                            }
                        } else {
                            ForEach(Array(viewModel.filteredSubscriptions.enumerated()), id: \.element.id) { index, subscription in
                                SubscriptionCell(
                                    subscription: subscription,
                                    onDelete: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            viewModel.confirmDelete(subscription)
                                        }
                                    },
                                    onMarkPaid: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.markPaymentAsPaid(subscription)
                                        }
                                    },
                                    onEdit: {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        subscriptionToEdit = subscription
                                        showingEditSubscription = true
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                            }
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
                .opacity(contentOpacity)
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.subscriptions = subscriptions
            
            // Animate content appearance
            withAnimation(.easeOut(duration: 0.6)) {
                headerOffset = 0
                contentOpacity = 1.0
            }
        }
        .onChange(of: subscriptions) { oldValue, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                viewModel.subscriptions = newValue
            }
        }
        .alert("Delete Subscription", isPresented: $viewModel.showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let subscription = viewModel.subscriptionToDelete {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.deleteSubscription(subscription)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this subscription?")
        }
        .sheet(isPresented: $showingEditSubscription) {
            if let subscription = subscriptionToEdit {
                EditSubscriptionView(subscription: subscription)
            }
        }
    }
}

// MARK: - Empty Period State View
struct EmptyPeriodStateView: View {
    let period: String
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
            .onAppear {
                pulseAnimation = true
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No \(period) Subscriptions")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("You don't have any subscriptions with \(period.lowercased()) billing period")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                
                Text("Try selecting a different period or add a new subscription")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Image(systemName: "creditcard.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
            .onAppear {
                pulseAnimation = true
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Subscriptions Yet")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Add your first subscription to start tracking your payments")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "arrow.up.right")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.0), value: pulseAnimation)
                    
                    Text("Tap the + button in the header to get started")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .italic()
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DesignSystem.Spacing.md)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xxl)
    }
}

// MARK: - Date Formatters
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    MySubscriptionsView(showingAddSubscription: .constant(false))
}


 
