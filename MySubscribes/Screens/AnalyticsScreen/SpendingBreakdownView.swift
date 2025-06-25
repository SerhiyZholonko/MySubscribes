//
//  SpendingBreakdownView.swift
//  MySubscribes
//
//  Created by apple on 24.06.2025.
//

import SwiftUI
import Charts

//struct Subscription: Identifiable {
//    let id = UUID()
//    let name: String
//    let cost: Double
//}

//struct SubscriptionsPieChartView: View {
//    let subscriptions: [Subscription]
//
//    var body: some View {
//        Chart(subscriptions) {
//            SectorMark(
//                angle: .value("Cost", $0.cost),
//                innerRadius: .ratio(0.5),
//                angularInset: 2
//            )
//            .foregroundStyle(by: .value("Name", $0.name))
//        }
//        .frame(height: 300)
//        .overlay {
//            VStack {
//                Text("Total")
//                    .font(.caption)
//                Text("$\(subscriptions.map { $0.cost }.reduce(0, +), specifier: "%.2f")")
//                    .font(.title2)
//                    .bold()
//            }
//        }
//    }
//}

//struct SpendingBreakdownView: View {
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Spending Breakdown")
//                .font(.title2)
//                .padding(.bottom, 10)
//
//            SubscriptionsPieChartView(subscriptions: [
//                Subscription(name: "Netflix", cost: 15.99),
//                Subscription(name: "Spotify", cost: 9.99),
//                Subscription(name: "iCloud", cost: 2.99),
//                Subscription(name: "YouTube Premium", cost: 11.99)
//            ])
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    SpendingBreakdownView()
//}
//
//
//
//#Preview {
//    SubscriptionsPieChartView(subscriptions: [
//        Subscription(name: "Netflix", cost: 15.99),
//        Subscription(name: "Spotify", cost: 9.99),
//        Subscription(name: "iCloud", cost: 2.99),
//        Subscription(name: "YouTube Premium", cost: 11.99)
//    ])
//}
//#Preview {
//    SpendingBreakdownView()
//}
