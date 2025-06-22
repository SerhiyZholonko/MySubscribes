//
//  PaymentCalendarView.swift
//  MySubscribes
//
//  Created by apple on 22.06.2025.
//

import SwiftUI

struct PaymentCalendarView: View {
    var body: some View {
        HStack {
        VStack(alignment: .leading) {
           
                Text("Payment Calendar")
                    .font(.title)
                Text("Track your upcoming payments")
                    .foregroundStyle(.green)
                    Spacer()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PaymentCalendarView()
}
