//
//  ServiceNameView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI

// MARK: - Service Name View
struct ServiceNameView: View {
    @Binding var serviceNameText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Service Name")
            TextField("e.g., Netflix, Spotify", text: $serviceNameText)
                .frame(height: 50)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .shadow(
                            color: DesignSystem.Shadows.light,
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
    }
}

#Preview {
    ServiceNameView(serviceNameText: .constant("3"))
}
