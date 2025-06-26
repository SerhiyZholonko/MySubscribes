//
//  AnalyticsView.swift
//  MySubscribes
//
//  Created by apple on 23.06.2025.
//

//import SwiftUI
//import SwiftData

//struct AnalyticsView: View {
//    @Query private var subscriptions: [Subscription]
//    
//    // Computed property for total monthly spending
//    var totalMonthlySpending: Double {
//        subscriptions.reduce(0) { total, subscription in
//            switch subscription.billingPeriod.lowercased() {
//            case "weekly":
//                return total + (subscription.monthlyCost * 4.33) // Average weeks per month
//            case "yearly":
//                return total + (subscription.monthlyCost / 12)
//            default: // monthly
//                return total + subscription.monthlyCost
//            }
//        }
//    }
//    
//    // Computed property for total number of services
//    var totalServices: Int {
//        subscriptions.count
//    }
//
//    var body: some View {
//        VStack {
//            AnalyticsHeaderView()
//            ZStack {
//                VStack(alignment: .leading) {
//                    HStack {
//                        titleTextOverlayView(
//                            title: "Total Monthly",
//                            price: totalMonthlySpending
//                        )
//                        titleTextOverlayView(
//                            title: "Total Services",
//                            price: Double(totalServices)
//                        )
//                    }
//                    SpendingBreakdownView()
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray, lineWidth: 1)
//                        }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .padding()
//                Color.blue
//                    .opacity(0.1)
//            }
//        }
//    }
//}
import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Query private var subscriptions: [Subscription]
    
    // Computed property for total monthly spending
    var totalMonthlySpending: Double {
        subscriptions.reduce(0) { total, subscription in
            switch subscription.billingPeriod.lowercased() {
            case "weekly":
                return total + (subscription.monthlyCost * 4.33) // Average weeks per month
            case "yearly":
                return total + (subscription.monthlyCost / 12)
            default: // monthly
                return total + subscription.monthlyCost
            }
        }
    }
    
    // Computed property for total number of services
    var totalServices: Int {
        subscriptions.count
    }

    var body: some View {
        VStack {
            AnalyticsHeaderView()
            ZStack {
                Color.blue
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    HStack {
                        titleTextOverlayView(
                            title: "Total Monthly",
                            price: totalMonthlySpending,
                            isCurrency: true
                        )
                        titleTextOverlayView(
                            title: "Total Services",
                            price: Double(totalServices),
                            isCurrency: false
                        )
                    }
                    SpendingBreakdownView()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            }
//            ZStack {
//                VStack(alignment: .leading) {
//                    HStack {
//                        titleTextOverlayView(
//                            title: "Total Monthly",
//                            price: totalMonthlySpending,
//                            isCurrency: true
//                        )
//                        titleTextOverlayView(
//                            title: "Total Services",
//                            price: Double(totalServices),
//                            isCurrency: false
//                        )
//                    }
//                    SpendingBreakdownView()
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray, lineWidth: 1)
//                        }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                .padding()
//               
//            }
//            Color.blue
//                .opacity(0.1)
        }
    }
}
#Preview {
    AnalyticsView()
}


