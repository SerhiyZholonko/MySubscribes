//
//  MySubscriptionsView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI
import SwiftData


// MARK: - Views
struct MySubscriptionsView: View {
    @StateObject private var viewModel = SubscriptionsViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]
    
    var body: some View {
        VStack {
            SHeader()
            STotalMonthlySpendingView(viewModel: viewModel)
            
            ScrollView {
                if viewModel.subscriptions.isEmpty {
                    Text("No subscriptions yet")
                        .foregroundColor(.secondary)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.subscriptions) { subscription in
                            SubscriptionCell(
                                subscription: subscription,
                                onDelete: {
                                    viewModel.confirmDelete(subscription)
                                }
                            )
                        }
                    }
                    .padding(.top)
                }
            }
            Spacer()
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.subscriptions = subscriptions
        }
        .onChange(of: subscriptions) { oldValue, newValue in
            viewModel.subscriptions = newValue
        }
        .alert("Delete Subscription", isPresented: $viewModel.showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let subscription = viewModel.subscriptionToDelete {
                    viewModel.deleteSubscription(subscription)
                }
            }
        } message: {
            Text("Are you sure you want to delete this subscription?")
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


 
