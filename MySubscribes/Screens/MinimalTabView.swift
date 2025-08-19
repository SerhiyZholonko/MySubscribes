//
//  MinimalTabView.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

struct MinimalTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false
    @State private var underlineOffset: CGFloat = 0
    @State private var underlineWidth: CGFloat = 0
    @Namespace private var underlineNamespace
    
    let tabs = [
        MinimalTab(icon: "rectangle.stack.badge.minus", selectedIcon: "rectangle.stack.badge.minus", title: "Subscriptions"),
        MinimalTab(icon: "calendar.badge.checkmark", selectedIcon: "calendar.badge.checkmark", title: "Calendar"),
        MinimalTab(icon: "chart.pie", selectedIcon: "chart.pie.fill", title: "Analytics")
    ]
    
    var body: some View {
        ZStack {
            // Clean background - Adaptive
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab content
                ZStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Group {
                            switch index {
                            case 0:
                                MySubscriptionsView(showingAddSubscription: $showingAddSubscription)
                            case 1:
                                PaymentCalendarView()
                            case 2:
                                AnalyticsView()
                            default:
                                EmptyView()
                            }
                        }
                        .opacity(selectedTab == index ? 1 : 0)
                    }
                }
                
                // Minimal tab bar with underlines
                MinimalTabBar(
                    selectedTab: $selectedTab,
                    tabs: tabs,
                    underlineOffset: $underlineOffset,
                    underlineWidth: $underlineWidth,
                    namespace: underlineNamespace
                )
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
    }
}

// MARK: - Minimal Tab Bar
struct MinimalTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [MinimalTab]
    @Binding var underlineOffset: CGFloat
    @Binding var underlineWidth: CGFloat
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            // Thin separator line - Adaptive
            Rectangle()
                .fill(Color(light: Color.gray.opacity(0.2), dark: Color.gray.opacity(0.4)))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    MinimalTabButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        namespace: namespace,
                        action: {
                            selectedTab = index
                            
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    if selectedTab == index {
                                        underlineOffset = geometry.frame(in: .named("tabBar")).minX
                                        underlineWidth = geometry.size.width
                                    }
                                }
                                .onChange(of: selectedTab) { _, newValue in
                                    if newValue == index {
                                        underlineOffset = geometry.frame(in: .named("tabBar")).minX
                                        underlineWidth = geometry.size.width
                                    }
                                }
                        }
                    )
                }
            }
            .coordinateSpace(name: "tabBar")
            .background(DesignSystem.Colors.backgroundPrimary)
            .overlay(
                // Animated underline
                Rectangle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: underlineWidth, height: 3)
                    .offset(x: underlineOffset + underlineWidth / 2 - UIScreen.main.bounds.width / 2)
                , alignment: .bottom
            )
        }
        .background(
            DesignSystem.Colors.backgroundPrimary
                .shadow(
                    color: DesignSystem.Shadows.medium,
                    radius: 10,
                    x: 0,
                    y: -5
                )
        )
    }
}

// MARK: - Minimal Tab Button
struct MinimalTabButton: View {
    let tab: MinimalTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Simple icon
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                
                // Text with underline effect
                VStack(spacing: 2) {
                    Text(tab.title)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    
                    // Individual underline for text
                    if isSelected {
                        Rectangle()
                            .fill(DesignSystem.Colors.primary)
                            .frame(height: 1)
                            .matchedGeometryEffect(id: "textUnderline", in: namespace)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Alternative Style - Line Tab View
struct LineTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false
    @Namespace private var lineNamespace
    
    let tabs = [
        MinimalTab(icon: "square.grid.3x3", selectedIcon: "square.grid.3x3.fill", title: "Grid"),
        MinimalTab(icon: "list.bullet.indent", selectedIcon: "list.bullet.indent", title: "List"),
        MinimalTab(icon: "chart.bar.xaxis", selectedIcon: "chart.bar.xaxis", title: "Chart")
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.96, green: 0.97, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab content
                ZStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Group {
                            switch index {
                            case 0:
                                MySubscriptionsView(showingAddSubscription: $showingAddSubscription)
                            case 1:
                                PaymentCalendarView()
                            case 2:
                                AnalyticsView()
                            default:
                                EmptyView()
                            }
                        }
                        .opacity(selectedTab == index ? 1 : 0)
                    }
                }
                
                // Line-based tab bar
                LineTabBar(
                    selectedTab: $selectedTab,
                    tabs: tabs,
                    namespace: lineNamespace
                )
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
    }
}

// MARK: - Line Tab Bar
struct LineTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [MinimalTab]
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    LineTabButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        namespace: namespace,
                        action: {
                            selectedTab = index
                            
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                // Rounded rectangle with border
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Line Tab Button
struct LineTabButton: View {
    let tab: MinimalTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color.gray.opacity(0.7))
                
                // Title
                Text(tab.title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : Color.gray.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        // Selected background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.primary)
                            .matchedGeometryEffect(id: "selectedBackground", in: namespace)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Border Tab View
struct BorderTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false
    @Namespace private var borderNamespace
    
    let tabs = [
        MinimalTab(icon: "rectangle.stack.badge.plus", selectedIcon: "rectangle.stack.badge.plus.fill", title: "Subscriptions"),
        MinimalTab(icon: "calendar.badge.checkmark", selectedIcon: "calendar.badge.checkmark", title: "Calendar"),
        MinimalTab(icon: "chart.bar.doc.horizontal", selectedIcon: "chart.bar.doc.horizontal.fill", title: "Analytics")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab content
                ZStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Group {
                            switch index {
                            case 0:
                                MySubscriptionsView(showingAddSubscription: $showingAddSubscription)
                            case 1:
                                PaymentCalendarView()
                            case 2:
                                AnalyticsView()
                            default:
                                EmptyView()
                            }
                        }
                        .opacity(selectedTab == index ? 1 : 0)
                    }
                }
                
                // Border-based tab bar
                BorderTabBar(
                    selectedTab: $selectedTab,
                    tabs: tabs,
                    namespace: borderNamespace
                )
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
    }
}

// MARK: - Border Tab Bar
struct BorderTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [MinimalTab]
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                BorderTabButton(
                    tab: tab,
                    isSelected: selectedTab == index,
                    namespace: namespace,
                    action: {
                        selectedTab = index
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Border Tab Button
struct BorderTabButton: View {
    let tab: MinimalTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : Color.gray)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : Color.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                            .matchedGeometryEffect(id: "border", in: namespace)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Data Model
struct MinimalTab {
    let icon: String
    let selectedIcon: String
    let title: String
}

#Preview {
    MinimalTabView()
}