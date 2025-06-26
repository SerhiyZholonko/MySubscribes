//
//  SpendingBreakdownView.swift
//  MySubscribes
//
//  Created by apple on 24.06.2025.
//

//import SwiftUI
//import Charts
//import SwiftData
//
//
//struct SubscriptionsPieChartView: View {
//    let subscriptions: [Subscription]
//
//    var body: some View {
//        Chart(subscriptions) {
//            SectorMark(
//                angle: .value("Cost", $0.monthlyCost),
//                innerRadius: .ratio(0.5),
//                angularInset: 2
//            )
//            .foregroundStyle(by: .value("Name", $0.serviceName))
//        }
//        .frame(height: 300)
//        .overlay {
//            VStack {
//                Text("Total")
//                    .font(.caption)
//                Text("$\(subscriptions.map { $0.monthlyCost }.reduce(0, +), specifier: "%.2f")")
//                    .font(.title2)
//                    .bold()
//            }
//        }
//    }
//}
//
//struct SpendingBreakdownView: View {
//    @Query private var subscriptions: [Subscription]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Spending Breakdown")
//                .font(.title2)
//                .padding(.bottom, 10)
//
//            SubscriptionsPieChartView(subscriptions: subscriptions )
//        }
//        .padding()
//    }
//}
import SwiftUI
import Charts
import SwiftData

// MARK: - Chart Data Model
struct ChartDataPoint {
    let serviceName: String
    let cost: Double
}

// MARK: - Period Options
enum ChartPeriod: String, CaseIterable, Identifiable, Equatable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
}

// MARK: - Pie Chart View
struct SubscriptionsPieChartView: View {
    let chartData: [ChartDataPoint]
    let period: ChartPeriod
    
    private var totalCost: Double {
        chartData.map { $0.cost }.reduce(0, +)
    }

    var body: some View {
        Chart(chartData, id: \.serviceName) { dataPoint in
            SectorMark(
                angle: .value("Cost", dataPoint.cost),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(by: .value("Name", dataPoint.serviceName))
        }
        .frame(height: 300)
        .overlay {
            VStack {
                Text("Total \(period.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("$\(totalCost, specifier: "%.2f")")
                    .font(.title2)
                    .bold()
            }
        }
    }
}

// MARK: - Main Spending Breakdown View
struct SpendingBreakdownView: View {
    @Query private var subscriptions: [Subscription]
    @State private var selectedPeriod: ChartPeriod = .monthly
    
    // Function to calculate cost based on selected period
    private func calculateCostForPeriod(subscription: Subscription, period: ChartPeriod) -> Double {
        // Normalize to monthly cost first
        let monthlyCost: Double
        
        switch subscription.billingPeriod.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
        case "weekly":
            monthlyCost = subscription.monthlyCost * 4.33
        case "monthly":
            monthlyCost = subscription.monthlyCost
        case "yearly", "annual":
            monthlyCost = subscription.monthlyCost / 12
        default:
            monthlyCost = subscription.monthlyCost
        }
        
        // Convert to requested period
        switch period {
        case .weekly:
            return monthlyCost / 4.33
        case .monthly:
            return monthlyCost
        case .yearly:
            return monthlyCost * 12
        }
    }
    
    private var chartData: [ChartDataPoint] {
        subscriptions
            .filter { subscription in
                subscription.billingPeriod.lowercased().contains(selectedPeriod.rawValue.lowercased())
            }
            .map { subscription in
                let cost = calculateCostForPeriod(subscription: subscription, period: selectedPeriod)
                return ChartDataPoint(serviceName: subscription.serviceName, cost: cost)
            }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Spending Breakdown")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Current: \(selectedPeriod.rawValue)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
            
            // Period Selector using Picker
            Picker("Period", selection: $selectedPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Chart
            if !subscriptions.isEmpty {
                SubscriptionsPieChartView(chartData: chartData, period: selectedPeriod)
            } else {
                VStack {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No subscriptions to display")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
            }
            
            // Debug info (you can remove this later)
//            if !subscriptions.isEmpty {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Debug Info:")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                    
//                    ForEach(subscriptions, id: \.serviceName) { subscription in
//                        let cost = calculateCostForPeriod(subscription: subscription, period: selectedPeriod)
//                        Text("\(subscription.serviceName): $\(cost, specifier: "%.2f") (\(selectedPeriod.rawValue.lowercased()))")
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Text("Total: $\(chartData.map(\.cost).reduce(0, +), specifier: "%.2f")")
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.blue)
//                }
//                .padding(.top, 10)
//            }
        }
        .padding()
    }
}
#Preview {
    SpendingBreakdownView()
}
