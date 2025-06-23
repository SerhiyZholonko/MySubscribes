//
//  AnalyticsView.swift
//  MySubscribes
//
//  Created by apple on 23.06.2025.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Analytics")
                .font(.system(size: 28, weight: .bold))
            Text("Spending insights & trends")
                .foregroundStyle(.red)
            HStack {
                titleTextOverlayView(title: "Total Monthly", price: 78)
                titleTextOverlayView(title: "Total Services", price: 3)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

#Preview {
    AnalyticsView()
}
