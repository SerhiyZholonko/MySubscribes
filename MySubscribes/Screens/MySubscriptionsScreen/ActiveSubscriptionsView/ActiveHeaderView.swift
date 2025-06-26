
//  AHeader.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

//MARK: - Header
struct SHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("My Subscriptions")
                    .font(.system(size: 26, weight: .semibold))
                Text("Track your monthly spending")
                    .foregroundStyle(.purple)
            }
            
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
            }
            
            
        }
        .padding()
       
    }
}
