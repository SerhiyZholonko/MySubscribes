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
                  
                  Text("Payment Calendar")
                      .tabItem {
                          Image(systemName: "plus")
                          Text("Add")
                      }
            Text("Calendar")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            Text("Analytics")
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analitics")

                }
           // calendar
                
              }
        .tint(.purple)
   
   .padding()
    }
}

#Preview {
    STabView()
}
