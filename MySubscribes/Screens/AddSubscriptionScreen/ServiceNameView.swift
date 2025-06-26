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

#Preview {
    ServiceNameView(serviceNameText: .constant("3"))
}
