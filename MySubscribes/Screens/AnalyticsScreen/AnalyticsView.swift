//
//  AnalyticsView.swift
//  MySubscribes
//
//  Created by apple on 23.06.2025.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var subscriptions: [Subscription]
    @State private var showContent = false
    @State private var selectedPeriod: AnalyticsPeriod = .monthly
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced Header
                EnhancedAnalyticsHeaderView(
                    selectedPeriod: $selectedPeriod,
                    totalSubscriptions: subscriptions.count
                )
                .opacity(showContent ? 1.0 : 0)
                .offset(y: showContent ? 0 : -30)
                
                // Content
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Statistics Cards
                        AnalyticsStatsCardsView(
                            subscriptions: subscriptions,
                            selectedPeriod: selectedPeriod
                        )
                        .opacity(showContent ? 1.0 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Enhanced Chart Section
                        EnhancedSpendingChartView(
                            subscriptions: subscriptions,
                            selectedPeriod: selectedPeriod
                        )
                        .opacity(showContent ? 1.0 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Category Breakdown
                        CategoryBreakdownView(subscriptions: subscriptions)
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Spending Trends
                        SpendingTrendsView(subscriptions: subscriptions)
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Insights Section
                        SpendingInsightsView(subscriptions: subscriptions)
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
    }
}

// MARK: - Analytics Period Enum
enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .monthly: return "calendar"
        case .yearly: return "calendar.badge.clock"
        }
    }
}

#Preview {
    AnalyticsView()
}


