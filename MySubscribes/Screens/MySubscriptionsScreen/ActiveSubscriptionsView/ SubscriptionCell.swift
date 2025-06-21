//
//   SubscriptionCell.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct SubscriptionCell: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray)
                .opacity(0.2)
                .frame( height: 100)
            HStack {
                
                ZStack {
                   RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                    Image(systemName: "star.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 30))
                }
                .frame(width: 80, height: 80)
                VStack(alignment: .leading) {
                    Text("Netflix")
                    Text("Next: Jul 15 • 25 days")
                }
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text("$15.99")
                        Text("monthly")
                    }
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .font(.system(size: 20))
                }
               
                    
            }
            .padding(.horizontal)
            
        }
        .padding(.horizontal)
        
    }
}

#Preview {
    SubscriptionCell()
}
