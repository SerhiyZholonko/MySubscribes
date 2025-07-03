//
//  DesignSystem.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors
        static let primary = Color(red: 0.4, green: 0.2, blue: 0.8) // Deep Purple
        static let primaryLight = Color(red: 0.5, green: 0.3, blue: 0.9) // Light Purple
        static let accent = Color(red: 0.0, green: 0.8, blue: 0.6) // Teal
        static let accentLight = Color(red: 0.0, green: 0.9, blue: 0.7) // Light Teal
        
        // Background Gradients
        static let backgroundGradient = LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.97, blue: 1.0), // Very light blue
                Color(red: 0.98, green: 0.95, blue: 1.0)  // Very light purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [
                Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9),
                Color(red: 0.98, green: 0.98, blue: 1.0, opacity: 0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Service Colors (for subscription cards)
        static let netflix = Color(red: 0.9, green: 0.1, blue: 0.2)
        static let spotify = Color(red: 0.1, green: 0.8, blue: 0.3)
        static let apple = Color(red: 0.0, green: 0.5, blue: 1.0)
        static let amazon = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let disney = Color(red: 0.0, green: 0.3, blue: 0.8)
        
        // Status Colors
        static let success = Color(red: 0.0, green: 0.7, blue: 0.3)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
        
        // Text Colors
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.6)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.medium)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption.weight(.medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let strong = Color.black.opacity(0.2)
    }
}

// MARK: - Custom View Modifiers
struct CardStyle: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.cardGradient)
                    .shadow(
                        color: DesignSystem.Shadows.medium,
                        radius: isPressed ? 5 : 10,
                        x: 0,
                        y: isPressed ? 2 : 5
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: DesignSystem.Colors.primary.opacity(0.3),
                radius: isPressed ? 5 : 10,
                x: 0,
                y: isPressed ? 2 : 5
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(isPressed: Bool = false) -> some View {
        self.modifier(CardStyle(isPressed: isPressed))
    }
    
    func primaryButtonStyle(isPressed: Bool = false) -> some View {
        self.modifier(PrimaryButtonStyle(isPressed: isPressed))
    }
}