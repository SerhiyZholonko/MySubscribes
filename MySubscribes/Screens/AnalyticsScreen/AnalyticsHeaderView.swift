//
//  AnalyticsHeaderView.swift
//  MySubscribes
//
//  Created by apple on 26.06.2025.
//

import SwiftUI

struct AnalyticsHeaderView: View {
    var body: some View {
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
    }
}

#Preview {
    AnalyticsHeaderView()
}
