//
//  STotalMonthlySpendingView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct STotalMonthlySpendingView: View {
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .mint]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame( height: 100)
                        .shadow(radius: 5)
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Monthly Spending")
                        .font(.system(size: 18, weight: .semibold))
                    Text("$78.97")
                        .font(.system(size: 26, weight: .semibold))

                }
                .foregroundStyle(.white)
                Spacer()
                ZStack {
                    Circle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                    .opacity(0.5)
                    Image(systemName: "chart.bar.xaxis")
                }
                    
                
            }
            .padding(.horizontal)
            
           
        }
        .padding(.horizontal, 20)

        
    }
}

#Preview {
    STotalMonthlySpendingView()
}
