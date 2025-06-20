//
//  MySubscriptionsView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct MySubscriptionsView: View {
    var body: some View {
        VStack {
            SHeader()
            STotalMonthlySpendingView()
            ScrollView {
                ForEach(0..<5) { _ in
                    SubscriptionCell()
                }
                
            }
           
            Spacer()
                
        }
        
    }
}

#Preview {
    MySubscriptionsView()
}

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
