//
//  FloatingTabView.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

struct FloatingTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false
    @State private var dragOffset: CGFloat = 0
    @State private var tabBarOpacity: Double = 1.0
    @State private var tabBarScale: CGFloat = 1.0
    @State private var floatingOffset: CGFloat = 0
    @Namespace private var animationNamespace
    
    let tabs = [
        TabItem(icon: "doc.text.below.ecg", selectedIcon: "doc.text.below.ecg.fill", title: "Subscriptions"),
        TabItem(icon: "calendar.badge.checkmark", selectedIcon: "calendar.badge.checkmark", title: "Calendar"),
        TabItem(icon: "chart.line.uptrend.xyaxis", selectedIcon: "chart.line.uptrend.xyaxis", title: "Analytics")
    ]
    
    var body: some View {
        ZStack {
            // Premium gradient background
            ZStack {
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                // Floating gradient orbs
                FloatingGradientOrbs()
            }
            
            // Content with gesture detection
            GeometryReader { geometry in
                ZStack {
                    // Tab content with parallax effect
                    TabContent(
                        selectedTab: $selectedTab,
                        showingAddSubscription: $showingAddSubscription,
                        dragOffset: dragOffset
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                                
                                // Hide tab bar when scrolling (no animation)
                                let verticalDrag = abs(value.translation.height)
                                tabBarOpacity = max(0.3, 1.0 - verticalDrag / 200.0)
                                tabBarScale = max(0.9, 1.0 - verticalDrag / 500.0)
                                floatingOffset = min(20, verticalDrag / 10)
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                
                                // Reset drag state (no animation)
                                dragOffset = 0
                                tabBarOpacity = 1.0
                                tabBarScale = 1.0
                                floatingOffset = 0
                                
                                // Swipe to change tabs (no animation)
                                if value.translation.width > threshold && selectedTab > 0 {
                                    selectedTab -= 1
                                } else if value.translation.width < -threshold && selectedTab < tabs.count - 1 {
                                    selectedTab += 1
                                }
                            }
                    )
                    
                    // Premium floating tab bar
                    VStack {
                        Spacer()
                        
                        FloatingTabBar(
                            selectedTab: $selectedTab,
                            tabs: tabs,
                            namespace: animationNamespace
                        )
                        .opacity(tabBarOpacity)
                        .scaleEffect(tabBarScale)
                        .offset(y: floatingOffset)
                        .shadow(color: DesignSystem.Shadows.colored.opacity(tabBarOpacity), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
    }
}

// MARK: - Floating Gradient Orbs
struct FloatingGradientOrbs: View {
    @State private var animateOrbs = false
    
    var body: some View {
        ZStack {
            // Primary orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.3),
                            DesignSystem.Colors.primary.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: animateOrbs ? 50 : -50, y: animateOrbs ? -100 : 100)
                .blur(radius: 20)
            
            // Accent orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.accent.opacity(0.3),
                            DesignSystem.Colors.accent.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .offset(x: animateOrbs ? -80 : 80, y: animateOrbs ? 150 : -150)
                .blur(radius: 15)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                animateOrbs = true
            }
        }
    }
}

// MARK: - Tab Content
struct TabContent: View {
    @Binding var selectedTab: Int
    @Binding var showingAddSubscription: Bool
    let dragOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Use offset for smooth sliding animation with parallax
            HStack(spacing: 0) {
                MySubscriptionsView(showingAddSubscription: $showingAddSubscription)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: dragOffset * 0.3) // Parallax effect
                
                PaymentCalendarView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: dragOffset * 0.5)
                
                AnalyticsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: dragOffset * 0.7)
            }
            .offset(x: CGFloat(-selectedTab) * UIScreen.main.bounds.width + dragOffset)
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    let namespace: Namespace.ID
    
    @State private var hoveredTab: Int? = nil
    @State private var rippleEffect: [Bool] = [false, false, false]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                FloatingTabButton(
                    tab: tab,
                    isSelected: selectedTab == index,
                    isHovered: hoveredTab == index,
                    namespace: namespace,
                    showRipple: index < rippleEffect.count ? rippleEffect[index] : false,
                    action: {
                        // Trigger ripple effect
                        rippleEffect[index] = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            rippleEffect[index] = false
                        }
                        
                        selectedTab = index
                        
                        // Premium haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.prepare()
                        impactFeedback.impactOccurred()
                    }
                )
                .onHover { hovering in
                    hoveredTab = hovering ? index : nil
                }
                
                if index < tabs.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .background(
            ZStack {
                // Multi-layer glass effect
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 30)
                    .fill(DesignSystem.Colors.glassGradient)
                
                // Inner glow
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 0.5)
                
                // Selection indicator with premium animation
                if selectedTab < tabs.count {
                    GeometryReader { geometry in
                        let totalWidth = geometry.size.width
                        let itemWidth = totalWidth / CGFloat(tabs.count)
                        let xOffset = CGFloat(selectedTab) * itemWidth + itemWidth / 2
                        
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.2))
                                .frame(width: 64, height: 64)
                                .blur(radius: 10)
                            
                            // Inner selection circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            DesignSystem.Colors.primary.opacity(0.3),
                                            DesignSystem.Colors.primaryLight.opacity(0.1)
                                        ],
                                        center: .center,
                                        startRadius: 5,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.5)
                                )
                        }
                        .position(x: xOffset, y: geometry.size.height / 2)
                    }
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 15)
        .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
        .overlay(
            // Top shine effect
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(height: 40)
                .blur(radius: 2)
                .offset(y: -20)
                .mask(
                    RoundedRectangle(cornerRadius: 30)
                )
                .allowsHitTesting(false)
        )
    }
}

// MARK: - Floating Tab Button
struct FloatingTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let isHovered: Bool
    let namespace: Namespace.ID
    let showRipple: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            action()
            
            // Animate icon (no animation)
            iconRotation += 360
            iconScale = 1.3
            iconScale = 1.0
        }) {
            ZStack {
                // Ripple effect
                if showRipple {
                    Circle()
                        .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                        .scaleEffect(showRipple ? 2 : 0)
                        .opacity(showRipple ? 0 : 1)
                }
                
                VStack(spacing: 6) {
                    // Premium icon container
                    ZStack {
                        // Glow effect for selected state
                        if isSelected {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.3))
                                .frame(width: 44, height: 44)
                                .blur(radius: 8)
                                .scaleEffect(isPressed ? 0.9 : 1.1)
                        }
                        
                        Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                            .font(.system(size: isSelected ? 26 : 22, weight: .medium))
                            .foregroundStyle(
                                isSelected
                                ? LinearGradient(
                                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(width: 40, height: 40)
                    
                    // Premium title styling
                    Text(tab.title)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                        .foregroundStyle(
                            isSelected
                            ? LinearGradient(
                                colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(isSelected ? 1.0 : 0.8)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                }
                .frame(maxWidth: .infinity)
                .scaleEffect(isHovered ? 1.05 : 1.0)
            }
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


#Preview {
    FloatingTabView()
}
