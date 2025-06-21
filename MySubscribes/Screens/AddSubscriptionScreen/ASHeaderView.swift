//
//  ASHeaderView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI

struct ASHeaderView: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(.gray)
            }
            .padding(.trailing, 30)
            .padding(.leading)
            
                
            Text("Add Subscription")
                .font(.system(size: 24, weight: .semibold, design: .default))
            Spacer()

        }
        
    }
}

#Preview {
    ASHeaderView()
}
