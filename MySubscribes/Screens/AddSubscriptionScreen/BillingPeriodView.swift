//
//  BillingPeriodView.swift
//  MySubscribes
//
//  Created by apple on 22.06.2025.
//

import SwiftUI

// MARK: - Instant Button Style
struct InstantButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Billing Period View
struct BillingPeriodView: View {
    @Binding var selectedPeriod: String
    @State private var isExpanded = false
    let periods = ["Weekly", "Monthly", "Yearly"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Billing Period")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            VStack(spacing: 0) {
                // Main dropdown trigger - Simple Button
                Button(action: {
                    isExpanded.toggle()
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    HStack {
                        Text(selectedPeriod)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.primary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.surfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(InstantButtonStyle())
                
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(periods, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                                isExpanded = false
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }) {
                                HStack {
                                    Text(period)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                    Spacer()
                                    if period == selectedPeriod {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .background(
                                    period == selectedPeriod ? 
                                    DesignSystem.Colors.primary.opacity(0.1) : 
                                    Color.clear
                                )
                            }
                            .buttonStyle(InstantButtonStyle())
                            
                            if period != periods.last {
                                Divider()
                                    .background(DesignSystem.Colors.textTertiary.opacity(0.3))
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.surfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    BillingPeriodView(selectedPeriod: .constant("Weekly"))
}