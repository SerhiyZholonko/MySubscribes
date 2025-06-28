//
//  STotalMonthlySpendingView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//
//

//import SwiftUI
//import SwiftData
//
//enum BillingDisplayPeriod: String, CaseIterable {
//    case weekly = "Weekly"
//    case monthly = "Monthly"
//    case yearly = "Yearly"
//}
//struct STotalMonthlySpendingView: View {
//    @ObservedObject var viewModel: SubscriptionsViewModel
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            // Period selector
//            Picker("Billing Period", selection: $viewModel.selectedPeriod) {
//                ForEach(BillingDisplayPeriod.allCases, id: \.self) { period in
//                    Text(period.rawValue).tag(period)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal, 20)
//            
//            // Main spending card
//            ZStack {
//                // Background gradient
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [.purple, .mint]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(height: 120)
//                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//                
//                HStack {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(viewModel.periodTitle)
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundStyle(.white.opacity(0.9))
//                        
//                        Text("$\(viewModel.totalSpendingForPeriod, specifier: "%.2f")")
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundStyle(.white)
//                    }
//                    
//                    Spacer()
//                    
//                    // Icon container
//                    ZStack {
//                        Circle()
//                            .frame(width: 54, height: 54)
//                            .foregroundStyle(.white.opacity(0.25))
//                        
//                        Circle()
//                            .frame(width: 44, height: 44)
//                            .foregroundStyle(.white.opacity(0.15))
//                        
//                        Image(systemName: viewModel.iconForPeriod)
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundStyle(.white)
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//            .padding(.horizontal, 20)
//        }
//    }
//}

//#Preview {
//    STotalMonthlySpendingView()
//}
import SwiftUI
import SwiftData

struct STotalMonthlySpendingView: View {
      @ObservedObject var viewModel: SubscriptionsViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Period selector
            Picker("Billing Period", selection: $viewModel.selectedPeriod) {
                ForEach(BillingDisplayPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            // Main spending card
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .mint]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.periodTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        Text("$\(viewModel.totalSpendingForPeriod, specifier: "%.2f")")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    // Icon container
                    ZStack {
                        Circle()
                            .frame(width: 54, height: 54)
                            .foregroundStyle(.white.opacity(0.25))
                        
                        Circle()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(.white.opacity(0.15))
                        
                        Image(systemName: viewModel.iconForPeriod)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
        }
    }
}
