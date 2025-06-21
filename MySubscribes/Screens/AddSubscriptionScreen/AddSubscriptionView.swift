//
//  AddSubscriptionView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//

import SwiftUI

struct AddSubscriptionView: View {
    var body: some View {
        VStack {
            ASHeaderView()
            ZStack(alignment: .top){
                Color(.blue)
                    .opacity(0.1)
                VStack {
                    ServiceNameView()
                    MonthlyCostView()
                }
               
            }
        }
    }
}

#Preview {
    AddSubscriptionView()
}
