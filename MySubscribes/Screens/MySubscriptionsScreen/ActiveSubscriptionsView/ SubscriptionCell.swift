//
//   SubscriptionCell.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

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
private let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
}()
