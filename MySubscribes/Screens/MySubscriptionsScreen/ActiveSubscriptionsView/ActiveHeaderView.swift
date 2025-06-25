
//  AHeader.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

//struct ActiveHeaderView: View {
//    var body: some View {
//        HStack {
//            Text("Active Subscriptions")
//                .font(.system(size: 20, weight: .semibold, design: .default))
//            Spacer()
//            Text("3 services")
//                .font(.system(size: 16, weight: .semibold, design: .default))
//                .foregroundStyle(.gray)
//        }
//        .padding()
//    }
//}

//#Preview {
//    ActiveHeaderView()
//}
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
