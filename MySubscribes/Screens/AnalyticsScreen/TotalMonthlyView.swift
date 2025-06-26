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
    let isCurrency: Bool
    
    // Convenience initializer for currency values
    init(title: String, price: Double, isCurrency: Bool = true) {
        self.title = title
        self.price = price
        self.isCurrency = isCurrency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isCurrency {
                Text("$\(String(format: "%.2f", price))")
                    .font(.title2)
                    .fontWeight(.semibold)
            } else {
                Text("\(Int(price))")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .padding(.leading, 10)
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
