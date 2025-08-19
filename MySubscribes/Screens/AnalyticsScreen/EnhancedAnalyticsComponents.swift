//
//  EnhancedAnalyticsComponents.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Analytics Stats Cards View
struct AnalyticsStatsCardsView: View {
    let subscriptions: [Subscription]
    let selectedPeriod: AnalyticsPeriod
    @State private var animateValues = false
    
    private var statsData: [AnalyticsStatData] {
        [
            AnalyticsStatData(
                title: "Total \(selectedPeriod.rawValue)",
                value: totalSpending(for: selectedPeriod),
                icon: "dollarsign.circle.fill",
                color: DesignSystem.Colors.primary,
                isCurrency: true,
                trend: "+8.2%"
            ),
            AnalyticsStatData(
                title: "Active Services",
                value: Double(activeSubscriptions.count),
                icon: "app.badge.checkmark",
                color: DesignSystem.Colors.success,
                isCurrency: false,
                trend: "+2"
            ),
            AnalyticsStatData(
                title: "Avg per Service",
                value: averagePerService(for: selectedPeriod),
                icon: "chart.bar.fill",
                color: DesignSystem.Colors.accent,
                isCurrency: true,
                trend: "-3.1%"
            ),
            AnalyticsStatData(
                title: "Categories",
                value: Double(uniqueCategories.count),
                icon: "folder.circle.fill",
                color: DesignSystem.Colors.warning,
                isCurrency: false,
                trend: "0"
            )
        ]
    }
    
    private var activeSubscriptions: [Subscription] {
        filteredSubscriptions(for: selectedPeriod).filter { $0.isActive }
    }
    
    private var uniqueCategories: Set<String> {
        Set(filteredSubscriptions(for: selectedPeriod).map { $0.category })
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
            ForEach(Array(statsData.enumerated()), id: \.offset) { index, stat in
                AnalyticsStatCard(
                    data: stat,
                    animateValue: animateValues
                )
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                        animateValues = true
                    }
                }
            }
        }
    }
    
    // Filter subscriptions based on selected period
    private func filteredSubscriptions(for period: AnalyticsPeriod) -> [Subscription] {
        switch period {
        case .monthly:
            return subscriptions.filter { $0.billingPeriod == "Monthly" }
        case .yearly:
            return subscriptions.filter { $0.billingPeriod == "Yearly" }
        }
    }
    
    private func totalSpending(for period: AnalyticsPeriod) -> Double {
        let filtered = filteredSubscriptions(for: period)
        return filtered.reduce(0) { total, subscription in
            total + subscription.monthlyCost
        }
    }
    
    private func averagePerService(for period: AnalyticsPeriod) -> Double {
        let filtered = filteredSubscriptions(for: period)
        let total = totalSpending(for: period)
        return filtered.isEmpty ? 0 : total / Double(filtered.count)
    }
}

// MARK: - Analytics Stat Data
struct AnalyticsStatData {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    let isCurrency: Bool
    let trend: String
}

// MARK: - Analytics Stat Card
struct AnalyticsStatCard: View {
    let data: AnalyticsStatData
    let animateValue: Bool
    @State private var isPressed = false
    
    private var formattedValue: String {
        if data.isCurrency {
            return String(format: "$%.2f", animateValue ? data.value : 0)
        } else {
            return String(format: "%.0f", animateValue ? data.value : 0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header
            HStack {
                Image(systemName: data.icon)
                    .font(.title2)
                    .foregroundColor(data.color)
                    .scaleEffect(animateValue ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateValue)
                
                Spacer()
                
                // Trend indicator
                if !data.trend.isEmpty && data.trend != "0" {
                    HStack(spacing: 2) {
                        Image(systemName: data.trend.contains("+") ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text(data.trend)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(data.trend.contains("+") ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                }
            }
            
            // Value
            Text(formattedValue)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .animation(.easeInOut(duration: 0.8), value: animateValue)
            
            // Title
            Text(data.title)
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(2)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(.regularMaterial)
                .shadow(color: DesignSystem.Shadows.light, radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(data.color.opacity(0.2), lineWidth: 1)
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

// MARK: - Enhanced Spending Chart View
struct EnhancedSpendingChartView: View {
    let subscriptions: [Subscription]
    let selectedPeriod: AnalyticsPeriod
    @State private var showChart = false
    @State private var selectedChartType: ChartType = .pie
    
    private var chartData: [ChartDataPoint] {
        filteredSubscriptions(for: selectedPeriod).map { subscription in
            ChartDataPoint(
                serviceName: subscription.serviceName,
                cost: subscription.monthlyCost
            )
        }
        .sorted { $0.cost > $1.cost }
    }
    
    // Filter subscriptions based on selected period
    private func filteredSubscriptions(for period: AnalyticsPeriod) -> [Subscription] {
        switch period {
        case .monthly:
            return subscriptions.filter { $0.billingPeriod == "Monthly" }
        case .yearly:
            return subscriptions.filter { $0.billingPeriod == "Yearly" }
        }
    }
    
    private var totalCost: Double {
        chartData.reduce(0) { $0 + $1.cost }
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.accent)
                
                Text("Spending Breakdown")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                // Chart Type Selector
                Picker("Chart Type", selection: $selectedChartType) {
                    ForEach(ChartType.allCases) { type in
                        Image(systemName: type.icon)
                            .tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
            }
            
            let filteredSubs = filteredSubscriptions(for: selectedPeriod)
            if !filteredSubs.isEmpty {
                // Chart
                Group {
                    switch selectedChartType {
                    case .pie:
                        EnhancedPieChartView(
                            chartData: chartData,
                            totalCost: totalCost,
                            period: selectedPeriod
                        )
                    case .bar:
                        EnhancedBarChartView(
                            chartData: Array(chartData.prefix(8)),
                            period: selectedPeriod
                        )
                    }
                }
                .opacity(showChart ? 1.0 : 0)
                .scaleEffect(showChart ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showChart)
                .animation(.easeInOut(duration: 0.3), value: selectedChartType)
                
                // Top Services List
                if chartData.count > 3 {
                    TopServicesListView(chartData: Array(chartData.prefix(5)))
                }
            } else {
                EmptyChartView()
            }
        }
        .cardStyle()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                showChart = true
            }
        }
    }
    
}

// MARK: - Chart Type Enum
enum ChartType: String, CaseIterable, Identifiable {
    case pie = "Pie"
    case bar = "Bar"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .pie: return "chart.pie"
        case .bar: return "chart.bar"
        }
    }
}

// MARK: - Enhanced Pie Chart View
struct EnhancedPieChartView: View {
    let chartData: [ChartDataPoint]
    let totalCost: Double
    let period: AnalyticsPeriod
    
    var body: some View {
        Chart(chartData, id: \.serviceName) { dataPoint in
            SectorMark(
                angle: .value("Cost", dataPoint.cost),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(by: .value("Service", dataPoint.serviceName))
            .cornerRadius(4)
        }
        .frame(height: 300)
        .overlay {
            VStack(spacing: 4) {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text(String(format: "$%.2f", totalCost))
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(period.rawValue)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Enhanced Bar Chart View
struct EnhancedBarChartView: View {
    let chartData: [ChartDataPoint]
    let period: AnalyticsPeriod
    
    var body: some View {
        Chart(chartData, id: \.serviceName) { dataPoint in
            BarMark(
                x: .value("Service", dataPoint.serviceName),
                y: .value("Cost", dataPoint.cost)
            )
            .foregroundStyle(by: .value("Service", dataPoint.serviceName))
            .cornerRadius(4)
        }
        .frame(height: 300)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks(format: .currency(code: "USD"))
        }
    }
}

// MARK: - Top Services List View
struct TopServicesListView: View {
    let chartData: [ChartDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Top Services")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, dataPoint in
                HStack {
                    // Rank
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(rankColor(for: index))
                        )
                    
                    // Service name
                    Text(dataPoint.serviceName)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Cost
                    Text(String(format: "$%.2f", dataPoint.cost))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return DesignSystem.Colors.primary
        }
    }
}

// MARK: - Empty Chart View
struct EmptyChartView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text("No Data Available")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("Add subscriptions to see spending breakdown")
                .font(.subheadline)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
    }
}

