//
//  STabView.swift
//  MySubscribes
//
//  Created by apple on 20.06.2025.
//

import SwiftUI

struct STabView: View {
    @State private var selectedTab = 0
    @State private var tabAppearance = Array(repeating: false, count: 3)
    @State private var showingAddSubscription = false
    
    var body: some View {
        ZStack {
            // Background gradient
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                MySubscriptionsView(showingAddSubscription: $showingAddSubscription)
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 0 ? "list.bullet.circle.fill" : "list.bullet.circle")
                                .font(.system(size: 20))
                            Text("Subscriptions")
                                .font(.caption2)
                        }
                    }
                    .tag(0)
                
                PaymentCalendarView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 1 ? "calendar.circle.fill" : "calendar.circle")
                                .font(.system(size: 20))
                            Text("Calendar")
                                .font(.caption2)
                        }
                    }
                    .tag(1)
                
                AnalyticsView()
                    .tabItem {
                        VStack {
                            Image(systemName: selectedTab == 2 ? "chart.bar.doc.horizontal.fill" : "chart.bar.doc.horizontal")
                                .font(.system(size: 20))
                            Text("Analytics")
                                .font(.caption2)
                        }
                    }
                    .tag(2)
            }
            .tint(DesignSystem.Colors.primary)
            .onChange(of: selectedTab) { oldValue, newValue in
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                // Animate tab appearance
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    tabAppearance[newValue] = true
                }
            }
        }
        .onAppear {
            // Animate initial tab appearance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                tabAppearance[0] = true
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
    }
}

#Preview {
    STabView()
}
