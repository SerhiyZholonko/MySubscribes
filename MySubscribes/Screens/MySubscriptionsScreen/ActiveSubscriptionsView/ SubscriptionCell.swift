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
    @StateObject private var viewModel: SubscriptionCellViewModel
    
    init(subscription: Subscription, onDelete: @escaping () -> Void) {
        self.subscription = subscription
        self.onDelete = onDelete
        self._viewModel = StateObject(wrappedValue: SubscriptionCellViewModel(subscription: subscription))
    }
    
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
                        .fill(viewModel.serviceColor)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: viewModel.serviceIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                }
                .frame(width: 80, height: 80)
                
                // Service Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.serviceName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Next: \(viewModel.formattedNextPaymentDate) • \(viewModel.daysUntilPayment) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Cost and Delete
                HStack(spacing: 12) {
                    VStack(alignment: .trailing) {
                        Text("$\(viewModel.formattedCost)")
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
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}


