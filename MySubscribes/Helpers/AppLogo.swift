//
//  AppLogo.swift
//  MySubscribes
//
//  Created by Claude on 04.07.2025.
//

import SwiftUI

// MARK: - App Logo Component
struct AppLogo: View {
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 60, showText: Bool = false) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        if showText {
            HStack(spacing: 12) {
                logoIcon
                logoText
            }
        } else {
            logoIcon
        }
    }
    
    private var logoIcon: some View {
        Image("AppIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
            .shadow(color: .black.opacity(0.2), radius: size * 0.1, x: 0, y: size * 0.05)
    }
    
    private var logoText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("MySubscribes")
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Track & Manage")
                .font(.system(size: size * 0.18, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Logo Variants
extension AppLogo {
    static var small: AppLogo {
        AppLogo(size: 40, showText: false)
    }
    
    static var medium: AppLogo {
        AppLogo(size: 60, showText: false)
    }
    
    static var large: AppLogo {
        AppLogo(size: 80, showText: false)
    }
    
    static var withText: AppLogo {
        AppLogo(size: 60, showText: true)
    }
    
    static var largeWithText: AppLogo {
        AppLogo(size: 100, showText: true)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        AppLogo.small
        AppLogo.medium
        AppLogo.large
        AppLogo.withText
        AppLogo.largeWithText
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
