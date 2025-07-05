//
//  TabViewSelector.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

enum TabViewStyle: String, CaseIterable {
    case custom = "Custom Animated"
    case floating = "Floating"
    case minimal = "Minimal Underline"
}

struct TabViewSelector: View {
    @AppStorage("selectedTabViewStyle") private var selectedStyle: String = TabViewStyle.custom.rawValue
    
    var body: some View {
        Group {
            switch TabViewStyle(rawValue: selectedStyle) ?? .custom {
            case .custom:
                CustomTabView()
            case .floating:
                FloatingTabView()
            case .minimal:
                MinimalTabView()
            }
        }
    }
}

// Settings view to change tab style
struct TabStyleSettingsView: View {
    @AppStorage("selectedTabViewStyle") private var selectedStyle: String = TabViewStyle.custom.rawValue
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Choose Tab Bar Style")
                        .font(DesignSystem.Typography.title1)
                        .padding(.top)
                    
                    VStack(spacing: 12) {
                        ForEach(TabViewStyle.allCases, id: \.self) { style in
                            TabStyleOption(
                                style: style,
                                isSelected: selectedStyle == style.rawValue,
                                action: {
                                    withAnimation(.spring()) {
                                        selectedStyle = style.rawValue
                                    }
                                    
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    // Dismiss after selection
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct TabStyleOption: View {
    let style: TabViewStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
                    
                    Text(styleDescription)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(isSelected ? DesignSystem.Colors.primary : Color.white.opacity(0.9))
                    .shadow(
                        color: isSelected ? DesignSystem.Colors.primary.opacity(0.3) : Color.black.opacity(0.05),
                        radius: isSelected ? 10 : 5,
                        x: 0,
                        y: isSelected ? 5 : 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var styleDescription: String {
        switch style {
        case .custom:
            return "Modern design with smooth transitions"
        case .floating:
            return "Floating bar with gesture support"
        case .minimal:
            return "Clean design with text underlines"
        }
    }
}

#Preview {
    TabStyleSettingsView()
}