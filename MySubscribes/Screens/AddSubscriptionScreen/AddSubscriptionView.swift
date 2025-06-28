//
//  AddSubscriptionView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI
import SwiftData



// MARK: - View
struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = AddSubscriptionViewModel()
    
    var body: some View {
        VStack {
            ASHeaderView(
                onSave: viewModel.saveSubscription,
                onCancel: { dismiss() }
            )
            
            ZStack(alignment: .top) {
                Color(.blue)
                    .opacity(0.1)
                
                ScrollView {
                    ServiceNameView(serviceNameText: $viewModel.serviceNameText)
                    MonthlyCostView(monthlyCostText: $viewModel.monthlyCostText)
                    BillingPeriodView(selectedPeriod: $viewModel.selectedPeriod)
                    NextPaymentDateView(nextPaymentDate: $viewModel.nextPaymentDate)
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .overlay {
            if viewModel.showingAlert {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                        .scaleEffect(viewModel.showingAlert ? 1.2 : 0.5)
                        .animation(.spring(), value: viewModel.showingAlert)

                    Text(viewModel.alertMessage)
                        .font(.headline)
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewModel.showingAlert = false
                    }
                }
            }
        }
    }
}
