//
//  MySubscriptionsView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI
import SwiftData


//struct MySubscriptionsView: View {
//    @Query private var subscriptions: [Subscription]
//
//    var body: some View {
//        VStack {
//            SHeader()
//            STotalMonthlySpendingView()
//            ScrollView {
//                ForEach(subscriptions) { subscription in
//                    VStack(alignment: .leading) {
//                        Text(subscription.serviceName)
//                            .font(.headline)
//                        Text("$\(subscription.monthlyCost, specifier: "%.2f") - \(subscription.billingPeriod)")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        Text("Next payment: \(subscription.nextPaymentDate, formatter: dateFormatter)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                
//            }
//           
//            Spacer()
//                
//        }
//        
//    }
//}
import SwiftUI
import SwiftData

struct MySubscriptionsView: View {
    @Query private var subscriptions: [Subscription]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            SHeader()
            STotalMonthlySpendingView()
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(subscriptions) { subscription in
                        SubscriptionCell(
                            subscription: subscription,
                            onDelete: {
                                deleteSubscription(subscription)
                            }
                        )
                    }
                }
                .padding(.top)
            }
            Spacer()
        }
    }
    
    private func deleteSubscription(_ subscription: Subscription) {
        modelContext.delete(subscription)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete subscription: \(error)")
        }
    }
}

struct SubscriptionCell: View {
    let subscription: Subscription
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .opacity(0.2)
                .frame(height: 100)
            
            HStack {
                // Service Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(serviceColor)
                        .frame(width: 80, height: 80)
                    
                    // You can customize this based on service name
                    Image(systemName: serviceIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                }
                .frame(width: 80, height: 80)
                
                // Service Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.serviceName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Next: \(subscription.nextPaymentDate, formatter: shortDateFormatter) • \(daysUntilPayment) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Cost and Delete
                HStack(spacing: 12) {
                    VStack(alignment: .trailing) {
                        Text("$\(subscription.monthlyCost, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(subscription.billingPeriod.lowercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    // Computed properties for dynamic styling
    private var serviceColor: Color {
        switch subscription.serviceName.lowercased() {
        case "netflix":
            return .red
        case "spotify":
            return .green
        case "apple music":
            return .pink
        case "disney+", "disney plus":
            return .blue
        case "hulu":
            return .green
        case "amazon prime":
            return .orange
        default:
            return .blue
        }
    }
    
    private var serviceIcon: String {
        switch subscription.serviceName.lowercased() {
        case "netflix":
            return "tv"
        case "spotify", "apple music":
            return "music.note"
        case "disney+", "disney plus":
            return "star.fill"
        case "hulu":
            return "play.tv"
        case "amazon prime":
            return "shippingbox"
        default:
            return "star.fill"
        }
    }
    
    private var daysUntilPayment: Int {
        let calendar = Calendar.current
        let today = Date()
        let days = calendar.dateComponents([.day], from: today, to: subscription.nextPaymentDate).day ?? 0
        return max(0, days)
    }
}

// MARK: - Date Formatters
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

private let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
}()

// MARK: - Placeholder Views (you can replace these with your actual implementations)
//struct SHeader: View {
//    var body: some View {
//        Text("My Subscriptions")
//            .font(.largeTitle)
//            .fontWeight(.bold)
//            .padding()
//    }
//}

struct STotalMonthlySpendingView: View {
    @Query private var subscriptions: [Subscription]
    
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
    
    var body: some View {
        VStack {
            Text("Total Monthly Spending")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("$\(totalMonthlySpending, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}
#Preview {
    MySubscriptionsView()
}


 
