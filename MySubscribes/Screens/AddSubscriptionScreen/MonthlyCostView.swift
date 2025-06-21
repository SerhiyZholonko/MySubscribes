//
//  MonthlyCostView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI

struct MonthlyCostView: View {
    @State var monhlyCostText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Cost")
            
            HStack {
                TextField("$ 0.00", text: $monhlyCostText)
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
        if let value = Double(monhlyCostText) {
            monhlyCostText = String(format: "%.2f", value + 1)
        }
    }

    func decrementCost() {
        if let value = Double(monhlyCostText), value > 0 {
            monhlyCostText = String(format: "%.2f", value - 1)
        }
    }
}

#Preview {
    MonthlyCostView()
}
