//
//  AnalyticsHeaderView.swift
//  MySubscribes
//
//  Created by apple on 26.06.2025.
//

import SwiftUI

struct AnalyticsHeaderView: View {
    var body: some View {
        HStack {
        VStack (alignment: .leading){
            
                Text("Analytics")
                    .font(.system(size: 28, weight: .bold))
                Text("Spending insights & trends")
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(.leading)
    }
}

// MARK: - Enhanced Analytics Header View
struct EnhancedAnalyticsHeaderView: View {
    @Binding var selectedPeriod: AnalyticsPeriod
    let totalSubscriptions: Int
    @State private var showPeriodSelector = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Main Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analytics")
                        .font(DesignSystem.Typography.title1)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Spending insights & trends")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Subscription Count Badge
                HStack(spacing: 4) {
                    Image(systemName: "app.badge")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.accent)
                    
                    Text("\(totalSubscriptions)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.accent.opacity(0.1))
                )
            }
            
            // Period Selector
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showPeriodSelector.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: selectedPeriod.icon)
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text(selectedPeriod.rawValue)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Image(systemName: showPeriodSelector ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .rotationEffect(.degrees(showPeriodSelector ? 180 : 0))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.regularMaterial)
                            .shadow(color: DesignSystem.Shadows.light, radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Quick Stats
                HStack(spacing: 16) {
                    QuickStatView(
                        icon: "calendar.circle.fill",
                        value: "This Month",
                        color: DesignSystem.Colors.success
                    )
                    
                    QuickStatView(
                        icon: "arrow.up.circle.fill",
                        value: "+12%",
                        color: DesignSystem.Colors.primary
                    )
                }
            }
            
            // Period Options
            if showPeriodSelector {
                HStack(spacing: 8) {
                    ForEach(AnalyticsPeriod.allCases) { period in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPeriod = period
                                showPeriodSelector = false
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: period.icon)
                                    .font(.caption)
                                Text(period.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedPeriod == period ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary.opacity(0.1))
                            )
                            .foregroundColor(selectedPeriod == period ? .white : DesignSystem.Colors.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
}

// MARK: - Quick Stat View
struct QuickStatView: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

#Preview {
    EnhancedAnalyticsHeaderView(
        selectedPeriod: .constant(.monthly),
        totalSubscriptions: 12
    )
}
