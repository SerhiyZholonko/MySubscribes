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
        // Primary Brand Colors - Adaptive for Light/Dark Mode
        static let primary = Color("PrimaryColor")
        static let primaryLight = Color("PrimaryLightColor")
        static let primaryDark = Color("PrimaryDarkColor")
        static let accent = Color("AccentColor")
        static let accentLight = Color("AccentLightColor")
        
        // Glass morphism colors - Adaptive
        static let glassWhite = Color(light: Color.white.opacity(0.1), dark: Color.white.opacity(0.05))
        static let glassBackground = Color(light: Color.white.opacity(0.05), dark: Color.black.opacity(0.1))
        static let glassBorder = Color(light: Color.white.opacity(0.2), dark: Color.white.opacity(0.1))
        
        // Background Gradients - Adaptive for Light/Dark Mode
        static let backgroundGradient = LinearGradient(
            colors: [
                Color(light: Color(red: 0.94, green: 0.96, blue: 1.0), dark: Color(red: 0.06, green: 0.04, blue: 0.1)),
                Color(light: Color(red: 0.96, green: 0.94, blue: 1.0), dark: Color(red: 0.04, green: 0.06, blue: 0.1)),
                Color(light: Color(red: 0.98, green: 0.95, blue: 0.98), dark: Color(red: 0.02, green: 0.05, blue: 0.02))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let premiumGradient = LinearGradient(
            colors: [primary, primaryLight, accent.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let darkGradient = LinearGradient(
            colors: [
                Color(light: Color(red: 0.1, green: 0.1, blue: 0.2), dark: Color(red: 0.9, green: 0.9, blue: 0.8)),
                Color(light: Color(red: 0.15, green: 0.1, blue: 0.25), dark: Color(red: 0.85, green: 0.9, blue: 0.75))
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let cardGradient = LinearGradient(
            colors: [
                Color(light: Color.white.opacity(0.95), dark: Color(red: 0.3, green: 0.3, blue: 0.3)),
                Color(light: Color.white.opacity(0.85), dark: Color(red: 0.25, green: 0.25, blue: 0.25)),
                Color(light: Color(red: 0.98, green: 0.98, blue: 1.0, opacity: 0.8), dark: Color(red: 0.2, green: 0.2, blue: 0.2))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let glassGradient = LinearGradient(
            colors: [
                Color(light: Color.white.opacity(0.15), dark: Color.white.opacity(0.08)),
                Color(light: Color.white.opacity(0.05), dark: Color.white.opacity(0.02))
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
        
        // Text Colors - Adaptive
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(light: Color(red: 0.6, green: 0.6, blue: 0.6), dark: Color(red: 0.7, green: 0.7, blue: 0.7))
        static let textInverse = Color(light: Color.white, dark: Color.black)
        
        // Background Colors - Adaptive
        static let backgroundPrimary = Color(light: Color.white, dark: Color.black)
        static let backgroundSecondary = Color(light: Color(red: 0.98, green: 0.98, blue: 0.98), dark: Color(red: 0.08, green: 0.08, blue: 0.08))
        static let backgroundTertiary = Color(light: Color(red: 0.95, green: 0.95, blue: 0.97), dark: Color(red: 0.15, green: 0.15, blue: 0.17))
        
        // Surface Colors - Adaptive
        static let surfaceElevated = Color(light: Color.white, dark: Color(red: 0.1, green: 0.1, blue: 0.1))
        static let surfaceCard = Color(light: Color.white.opacity(0.9), dark: Color.black.opacity(0.8))
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
        static let light = Color(light: Color.black.opacity(0.08), dark: Color.white.opacity(0.04))
        static let medium = Color(light: Color.black.opacity(0.15), dark: Color.white.opacity(0.08))
        static let strong = Color(light: Color.black.opacity(0.25), dark: Color.white.opacity(0.12))
        static let colored = Color(light: Color(red: 0.35, green: 0.15, blue: 0.85).opacity(0.4), dark: Color(red: 0.65, green: 0.45, blue: 0.95).opacity(0.5))
        static let glow = Color(light: Color(red: 0.55, green: 0.35, blue: 0.95).opacity(0.6), dark: Color(red: 0.75, green: 0.55, blue: 1.0).opacity(0.7))
    }
    
    // MARK: - Animations
    struct Animations {
        static let quick = Animation.easeInOut(duration: 0.2)
        static let medium = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let gentle = Animation.easeOut(duration: 0.3)
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
                        radius: isPressed ? 8 : 15,
                        x: 0,
                        y: isPressed ? 4 : 8
                    )
                    .shadow(
                        color: DesignSystem.Shadows.light,
                        radius: isPressed ? 3 : 6,
                        x: 0,
                        y: isPressed ? 2 : 4
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

// MARK: - Color Extensions
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    
    // Quick access to adaptive colors
    static let adaptiveBackground = Color(light: .white, dark: .black)
    static let adaptiveText = Color(light: .black, dark: .white)
    static let adaptiveSecondary = Color(light: .gray, dark: Color(white: 0.7))
}

// MARK: - View Extensions
extension View {
    func cardStyle(isPressed: Bool = false) -> some View {
        self.modifier(CardStyle(isPressed: isPressed))
    }
    
    func primaryButtonStyle(isPressed: Bool = false) -> some View {
        self.modifier(PrimaryButtonStyle(isPressed: isPressed))
    }
    
    // Dark mode adaptive modifiers
    func adaptiveBackground() -> some View {
        self.background(DesignSystem.Colors.backgroundPrimary)
    }
    
    func adaptiveTextColor() -> some View {
        self.foregroundColor(DesignSystem.Colors.textPrimary)
    }
}
