//
//  AHeader.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct ActiveHeaderView: View {
    var body: some View {
        HStack {
            Text("Active Subscriptions")
                .font(.system(size: 20, weight: .semibold, design: .default))
            Spacer()
            Text("3 services")
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundStyle(.gray)
        }
        .padding()
    }
}

#Preview {
    ActiveHeaderView()
}
