//
//  TotalMonthlyView.swift
//  MySubscribes
//
//  Created by apple on 23.06.2025.
//

import SwiftUI

struct titleTextOverlayView: View {
    let title: String
    let price: Double
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Text("$\(String(format: "%.2f", price))")
        }
        .padding(.leading, 10) // move text left
        .frame(width: 150, height: 80, alignment: .leading)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        }
    }
}

#Preview {
    titleTextOverlayView(title: "Total Monthly", price: 78)
}
