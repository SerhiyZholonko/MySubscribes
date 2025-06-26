//
//  MySubscriptionsView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

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



// MARK: - Date Formatters
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()


#Preview {
    MySubscriptionsView()
}


 
