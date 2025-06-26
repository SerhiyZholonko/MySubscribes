//
//  ASHeaderView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI

// MARK: - Header View
struct ASHeaderView: View {
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(.gray)
            }
            .padding(.trailing, 30)
            .padding(.leading)
            
            Text("Add Subscription")
                .font(.system(size: 24, weight: .semibold, design: .default))
            
            Spacer()
            
            Button("Save", action: onSave)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.trailing)
    }
}

#Preview {
    ASHeaderView(onSave: {}, onCancel: {})
}
