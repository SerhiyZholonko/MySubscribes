//
//  NextPaymentDateView.swift
//  MySubscribes
//
//  Created by apple on 22.06.2025.
//

import SwiftUI

// MARK: - Next Payment Date View
struct NextPaymentDateView: View {
    @Binding var nextPaymentDate: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Payment Date")
            DatePicker("", selection: $nextPaymentDate, displayedComponents: .date)
                .datePickerStyle(.compact)
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
}
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    NextPaymentDateView(nextPaymentDate: .constant(Date()))
}
