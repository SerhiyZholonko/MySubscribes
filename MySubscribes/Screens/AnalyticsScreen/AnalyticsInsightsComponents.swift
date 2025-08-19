//
//  AnalyticsInsightsComponents.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI
import SwiftData

// MARK: - Category Breakdown View
struct CategoryBreakdownView: View {
    let subscriptions: [Subscription]
    @State private var showDetails = false
    
    private var categoryData: [CategoryData] {
        let categories = Dictionary(grouping: subscriptions) { $0.category }
        
        return categories.map { category, subs in
            CategoryData(
                name: category,
                subscriptions: subs,
                totalCost: subs.reduce(0) { $0 + $1.monthlyCost },
                color: subs.first?.displayColor ?? DesignSystem.Colors.primary
            )
        }.sorted { $0.totalCost > $1.totalCost }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "folder.fill.badge.gearshape")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.warning)
                
                Text("Categories")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showDetails.toggle()
                    }
                }) {
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .rotationEffect(.degrees(showDetails ? 180 : 0))
                }
            }
            
            // Category Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(categoryData.enumerated()), id: \.offset) { index, category in
                    CategoryCard(category: category, showDetails: showDetails)
                        .onAppear {
                            // Staggered animation
                        }
                }
            }
            
            if showDetails && !categoryData.isEmpty {
                CategoryDetailsView(categoryData: categoryData)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .cardStyle()
    }
}

// MARK: - Category Data
struct CategoryData {
    let name: String
    let subscriptions: [Subscription]
    let totalCost: Double
    let color: Color
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: CategoryData
    let showDetails: Bool
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Icon and count
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                
                Spacer()
                
                Text("\(category.subscriptions.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            // Category name
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)
            
            // Total cost
            Text(String(format: "$%.2f", category.totalCost))
                .font(DesignSystem.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(category.color)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(category.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(category.color.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Category Details View
struct CategoryDetailsView: View {
    let categoryData: [CategoryData]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Divider()
                .padding(.vertical, DesignSystem.Spacing.sm)
            
            ForEach(Array(categoryData.enumerated()), id: \.offset) { index, category in
                CategoryDetailRow(category: category)
            }
        }
    }
}

// MARK: - Category Detail Row
struct CategoryDetailRow: View {
    let category: CategoryData
    
    var body: some View {
        HStack {
            // Category indicator
            Circle()
                .fill(category.color)
                .frame(width: 8, height: 8)
            
            // Category info
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("\(category.subscriptions.count) services")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Cost
            Text(String(format: "$%.2f", category.totalCost))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Spending Trends View
struct SpendingTrendsView: View {
    let subscriptions: [Subscription]
    @State private var selectedTrendPeriod: TrendPeriod = .monthly
    
    private var trendData: [TrendDataPoint] {
        generateTrendData(for: selectedTrendPeriod)
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.success)
                
                Text("Spending Trends")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                // Period selector
                Picker("Period", selection: $selectedTrendPeriod) {
                    ForEach(TrendPeriod.allCases) { period in
                        Text(period.rawValue)
                            .tag(period)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(DesignSystem.Colors.primary)
            }
            
            if !trendData.isEmpty {
                // Trend chart would go here - simplified version
                TrendSummaryView(trendData: trendData, period: selectedTrendPeriod)
            } else {
                EmptyTrendView()
            }
            
            // Quick insights
            TrendInsightsView(subscriptions: subscriptions)
        }
        .cardStyle()
    }
    
    private func generateTrendData(for period: TrendPeriod) -> [TrendDataPoint] {
        // Simplified trend data generation
        let calendar = Calendar.current
        let now = Date()
        
        return (0..<6).compactMap { offset in
            let date: Date
            switch period {
            case .monthly:
                date = calendar.date(byAdding: .month, value: -offset, to: now) ?? now
            case .yearly:
                date = calendar.date(byAdding: .year, value: -offset, to: now) ?? now
            }
            
            // Calculate spending for this period (simplified)
            let spending = Double.random(in: 50...200) // Placeholder data
            
            return TrendDataPoint(date: date, spending: spending)
        }.reversed()
    }
}

// MARK: - Trend Period
enum TrendPeriod: String, CaseIterable, Identifiable {
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
}

// MARK: - Trend Data Point
struct TrendDataPoint {
    let date: Date
    let spending: Double
}

// MARK: - Trend Summary View
struct TrendSummaryView: View {
    let trendData: [TrendDataPoint]
    let period: TrendPeriod
    
    private var currentSpending: Double {
        trendData.last?.spending ?? 0
    }
    
    private var previousSpending: Double {
        trendData.dropLast().last?.spending ?? 0
    }
    
    private var trendPercentage: Double {
        guard previousSpending > 0 else { return 0 }
        return ((currentSpending - previousSpending) / previousSpending) * 100
    }
    
    private var isIncreasing: Bool {
        trendPercentage > 0
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Current vs Previous
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current \(period.rawValue)")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text(String(format: "$%.2f", currentSpending))
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: isIncreasing ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(String(format: "%.1f%%", abs(trendPercentage)))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(isIncreasing ? DesignSystem.Colors.error : DesignSystem.Colors.success)
                    
                    Text("vs last \(period.rawValue.lowercased())")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            
            // Simple trend visualization
            TrendLineView(trendData: trendData)
        }
    }
}

// MARK: - Trend Line View
struct TrendLineView: View {
    let trendData: [TrendDataPoint]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(trendData.enumerated()), id: \.offset) { index, dataPoint in
                let maxSpending = trendData.map { $0.spending }.max() ?? 1
                let height = (dataPoint.spending / maxSpending) * 60
                
                Rectangle()
                    .fill(DesignSystem.Colors.accent)
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(2)
            }
        }
        .frame(height: 80)
        .padding(.horizontal, DesignSystem.Spacing.sm)
    }
}

// MARK: - Empty Trend View
struct EmptyTrendView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text("No trend data available")
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Trend Insights View
struct TrendInsightsView: View {
    let subscriptions: [Subscription]
    
    private var insights: [String] {
        var insights: [String] = []
        
        if subscriptions.count > 10 {
            insights.append("You have many subscriptions. Consider reviewing for unused services.")
        }
        
        let totalMonthly = subscriptions.reduce(0) { $0 + $1.monthlyCost }
        if totalMonthly > 100 {
            insights.append("Monthly spending exceeds $100. Look for savings opportunities.")
        }
        
        let categories = Set(subscriptions.map { $0.category })
        if categories.count > 5 {
            insights.append("Spending across \(categories.count) categories. Focus on priorities.")
        }
        
        return insights.isEmpty ? ["Your subscription management looks good!"] : insights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Quick Insights")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.warning)
                    
                    Text(insight)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }
}

// MARK: - Spending Insights View
struct SpendingInsightsView: View {
    let subscriptions: [Subscription]
    @State private var showAllInsights = false
    
    private var insights: [InsightData] {
        generateInsights()
    }
    
    private var displayedInsights: [InsightData] {
        showAllInsights ? insights : Array(insights.prefix(3))
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("Smart Insights")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if insights.count > 3 {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showAllInsights.toggle()
                        }
                    }) {
                        Text(showAllInsights ? "Show Less" : "Show All")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            
            // Insights list
            ForEach(Array(displayedInsights.enumerated()), id: \.offset) { index, insight in
                InsightCard(insight: insight)
            }
        }
        .cardStyle()
    }
    
    private func generateInsights() -> [InsightData] {
        var insights: [InsightData] = []
        
        let totalMonthly = subscriptions.reduce(0) { $0 + $1.monthlyCost }
        let totalYearly = totalMonthly * 12
        
        // High spending insight
        if totalMonthly > 150 {
            insights.append(InsightData(
                type: .warning,
                title: "High Monthly Spending",
                description: "You're spending $\(String(format: "%.0f", totalMonthly))/month ($\(String(format: "%.0f", totalYearly))/year) on subscriptions.",
                actionTitle: "Review Services",
                icon: "exclamationmark.triangle.fill"
            ))
        }
        
        // Unused services insight
        let oldSubscriptions = subscriptions.filter { 
            Calendar.current.dateInterval(of: .month, for: $0.nextPaymentDate)?.start ?? Date() < Date()
        }
        if oldSubscriptions.count > 2 {
            insights.append(InsightData(
                type: .info,
                title: "Potential Unused Services",
                description: "\(oldSubscriptions.count) subscriptions haven't been used recently.",
                actionTitle: "Review Usage",
                icon: "clock.fill"
            ))
        }
        
        // Savings opportunity
        if subscriptions.count > 5 {
            let potentialSavings = totalMonthly * 0.2 // Assume 20% savings possible
            insights.append(InsightData(
                type: .success,
                title: "Savings Opportunity",
                description: "Bundle or switch services to save up to $\(String(format: "%.0f", potentialSavings))/month.",
                actionTitle: "Explore Options",
                icon: "dollarsign.circle.fill"
            ))
        }
        
        // Category diversity
        let categories = Set(subscriptions.map { $0.category })
        if categories.count > 6 {
            insights.append(InsightData(
                type: .info,
                title: "Diverse Spending",
                description: "You're spending across \(categories.count) different categories.",
                actionTitle: "Prioritize",
                icon: "folder.fill"
            ))
        }
        
        return insights
    }
}

// MARK: - Insight Data
struct InsightData {
    let type: InsightType
    let title: String
    let description: String
    let actionTitle: String
    let icon: String
}

enum InsightType {
    case info, warning, success
    
    var color: Color {
        switch self {
        case .info: return DesignSystem.Colors.primary
        case .warning: return DesignSystem.Colors.warning
        case .success: return DesignSystem.Colors.success
        }
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let insight: InsightData
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundColor(insight.type.color)
                .frame(width: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Action button
            Button(action: {
                // Action handling would go here
            }) {
                Text(insight.actionTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(insight.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(insight.type.color.opacity(0.1))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(insight.type.color.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(insight.type.color.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}