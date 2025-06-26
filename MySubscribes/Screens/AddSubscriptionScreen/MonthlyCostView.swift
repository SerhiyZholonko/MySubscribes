//
//  MonthlyCostView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI

// MARK: - Monthly Cost View
struct MonthlyCostView: View {
    @Binding var monthlyCostText: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Cost")
            
            HStack {
                TextField("$ 0.00", text: $monthlyCostText)
                    .keyboardType(.decimalPad)
                
                VStack(spacing: 0) {
                    Button(action: { incrementCost() }) {
                        Image(systemName: "chevron.up")
                    }
                    Button(action: { decrementCost() }) {
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .padding()
    }
    
    func incrementCost() {
        if let value = Double(monthlyCostText) {
            monthlyCostText = String(format: "%.2f", value + 1)
        }
    }

    func decrementCost() {
        if let value = Double(monthlyCostText), value > 0 {
            monthlyCostText = String(format: "%.2f", value - 1)
        }
    }
}


#Preview {
    MonthlyCostView(monthlyCostText: .constant("$ 0.00"))
}
