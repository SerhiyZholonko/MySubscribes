//
//  AnalyticsView.swift
//  MySubscribes
//
//  Created by apple on 23.06.2025.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack {
            HStack {
            VStack (alignment: .leading){
                
                    Text("Analytics")
                        .font(.system(size: 28, weight: .bold))
                    Text("Spending insights & trends")
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .padding(.leading)
            
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        titleTextOverlayView(title: "Total Monthly", price: 78)
                        titleTextOverlayView(title: "Total Services", price: 3)
                    }
                    SpendingBreakdownView()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                Color.blue
                    .opacity(0.1)
               
            }
          
            
        }
        
    }
}

#Preview {
    AnalyticsView()
}
