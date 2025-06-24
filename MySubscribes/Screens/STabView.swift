//
//  STabView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct STabView: View {
    var body: some View {
        TabView {
            MySubscriptionsView()
                      .tabItem {
                          Image(systemName: "list.bullet")
                          Text("Subscriptions")
                      }
                  
            AddSubscriptionView()
                      .tabItem {
                          Image(systemName: "plus")
                          Text("Add")
                      }
            PaymentCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analitics")

                }
                
              }
        .tint(.purple)
   
//   .padding()
    }
}

#Preview {
    STabView()
}
