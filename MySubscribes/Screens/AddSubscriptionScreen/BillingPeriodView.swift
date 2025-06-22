//
//  BillingPeriodView.swift
//  MySubscribes
//
//  Created by apple on 22.06.2025.
//

import SwiftUI

struct BillingPeriodView: View {
    @State private var selectedPeriod = "Monthly"
    @State private var isExpanded = false
    let periods = ["Weekly", "Monthly", "Yearly"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Billing Period")
            VStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedPeriod)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(periods, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                                withAnimation {
                                    isExpanded = false
                                }
                            }) {
                                HStack {
                                    Text(period)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if period == selectedPeriod {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if period != periods.last {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .shadow(radius: 5)
                }
            }
        }
        .padding()
    }
}

#Preview {
    BillingPeriodView()
}
