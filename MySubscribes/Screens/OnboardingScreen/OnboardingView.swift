//
//  OnboardingView.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    @State private var showMainApp = false
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Animated Background
            DesignSystem.Colors.backgroundGradient
                .ignoresSafeArea()
            
            if showMainApp {
                STabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                VStack(spacing: 0) {
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            OnboardingPageView(page: page, pageIndex: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    // Bottom Controls
                    OnboardingBottomControls(
                        currentPage: $currentPage,
                        totalPages: pages.count,
                        onGetStarted: {
                            completeOnboarding()
                        }
                    )
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
            }
        }
        .onAppear {
            if hasSeenOnboarding {
                showMainApp = true
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            hasSeenOnboarding = true
            showMainApp = true
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let primaryColor: Color
    let secondaryColor: Color
    
    static let allPages = [
        OnboardingPage(
            title: "Track Your Subscriptions",
            subtitle: "Never miss a payment again. Keep all your subscriptions organized in one beautiful app.",
            imageName: "creditcard.circle.fill",
            primaryColor: DesignSystem.Colors.primary,
            secondaryColor: DesignSystem.Colors.primaryLight
        ),
        OnboardingPage(
            title: "Smart Notifications",
            subtitle: "Get timely reminders before your payments are due. Stay on top of your finances effortlessly.",
            imageName: "bell.circle.fill",
            primaryColor: DesignSystem.Colors.accent,
            secondaryColor: DesignSystem.Colors.accentLight
        ),
        OnboardingPage(
            title: "Spending Analytics",
            subtitle: "Understand your spending patterns with beautiful charts and insights. Make informed decisions.",
            imageName: "chart.bar.doc.horizontal.fill",
            primaryColor: DesignSystem.Colors.success,
            secondaryColor: Color.green.opacity(0.7)
        )
    ]
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @State private var imageScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    @State private var titleOffset: CGFloat = 50
    @State private var subtitleOffset: CGFloat = 30
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            
            // Animated Icon
            ZStack {
                // Background circles with pulse animation
                ForEach(0..<3) { index in
                    Circle()
                        .fill(page.primaryColor.opacity(0.1 - Double(index) * 0.03))
                        .frame(width: 200 + CGFloat(index * 40), height: 200 + CGFloat(index * 40))
                        .scaleEffect(imageScale)
                        .animation(
                            .easeInOut(duration: 2.0 + Double(index) * 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: imageScale
                        )
                }
                
                // Main icon
                Image(systemName: page.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.primaryColor, page.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(imageScale)
                    .rotationEffect(.degrees(imageScale == 1.0 ? 0 : -10))
            }
            .frame(height: 300)
            
            // Text Content
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(page.title)
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .offset(y: titleOffset)
                
                Text(page.subtitle)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .opacity(textOpacity)
                    .offset(y: subtitleOffset)
            }
            
            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Image animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
            imageScale = 1.0
        }
        
        // Title animation
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            titleOffset = 0
            textOpacity = 1.0
        }
        
        // Subtitle animation
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            subtitleOffset = 0
        }
    }
}

// MARK: - Bottom Controls
struct OnboardingBottomControls: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onGetStarted: () -> Void
    
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Page Indicators
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(0..<totalPages, id: \.self) { index in
                    PageIndicator(
                        isActive: index == currentPage,
                        color: index <= currentPage ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Action Buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    }
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer()
                
                if currentPage < totalPages - 1 {
                    Button("Next") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                    .primaryButtonStyle()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Button("Get Started") {
                        onGetStarted()
                    }
                    .primaryButtonStyle()
                    .scaleEffect(buttonScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            buttonScale = 1.05
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Page Indicator
struct PageIndicator: View {
    let isActive: Bool
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: isActive ? 24 : 8, height: 8)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    OnboardingView()
}