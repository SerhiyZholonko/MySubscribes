//
//  AddSubscriptionView.swift
//  MySubscribes
//
//  Created by apple on 21.06.2025.
//
import SwiftUI
import SwiftData

// MARK: - Keyboard Dismissal Extension
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - View
struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = AddSubscriptionViewModel()
    @State private var showContent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    ModalHeaderView(
                        title: "Add Subscription",
                        onSave: {
                            hideKeyboard()
                            viewModel.saveSubscription()
                        },
                        onCancel: {
                            hideKeyboard()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismiss()
                            }
                        }
                    )
                    .opacity(showContent ? 1.0 : 0)
                    .offset(y: showContent ? 0 : -30)
                    
                    // Form Content
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            // Basic Information
                            ServiceNameView(serviceNameText: $viewModel.serviceNameText)
                                .opacity(showContent ? 1.0 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            MonthlyCostView(monthlyCostText: $viewModel.monthlyCostText)
                                .opacity(showContent ? 1.0 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            BillingPeriodView(selectedPeriod: $viewModel.selectedPeriod)
                                .opacity(showContent ? 1.0 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            // Enhanced Date Picker
                            EnhancedDatePickerView(nextPaymentDate: $viewModel.nextPaymentDate)
                                .opacity(showContent ? 1.0 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            // Repetition Settings
                            RepetitionSettingsView(
                                isRecurring: $viewModel.isRecurring,
                                endDate: $viewModel.endDate
                            )
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                            
                            // Category Selection
                            CategorySelectionView(
                                selectedCategory: $viewModel.selectedCategory,
                                categories: viewModel.categories
                            )
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                            
                            // Color Selection
                            ColorSelectionView(
                                selectedColor: $viewModel.selectedColor,
                                colors: viewModel.colors
                            )
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                            
                            // Reminder Settings
                            ReminderSettingsView(
                                reminderDays: $viewModel.reminderDays,
                                reminderOptions: viewModel.reminderOptions
                            )
                            .opacity(showContent ? 1.0 : 0)
                            .offset(y: showContent ? 0 : 20)
                            
                            // Notes
                            NotesView(notes: $viewModel.notes)
                                .opacity(showContent ? 1.0 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.top, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
        .onAppear {
            viewModel.setModelContext(modelContext)
            
            // Animate content appearance
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showContent = true
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                withAnimation(.easeInOut(duration: 0.3)) {
                    dismiss()
                }
            }
        }
        .overlay {
                       if viewModel.showingAlert {
                           ZStack {
                               // Background overlay
                               Color.black
                                   .opacity(0.2)
                                   .ignoresSafeArea()
                                   .transition(.opacity)
                               
                               // Enhanced alert
                               EnhancedAlert(
                                   message: viewModel.alertMessage,
                                   isShowing: $viewModel.showingAlert
                               )
                           }
                           .transition(.opacity)
                       }            
        }
    }
}

// MARK: - Enhanced Alert Animation
struct EnhancedAlert: View {
    let message: String
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var offset: CGFloat = -50
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with pulse animation
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(.green)
                        .frame(width: 80, height: 80)
                )
                .scaleEffect(scale)
                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Message text
            Text(message)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            showAlert()
        }
        .onChange(of: isShowing) { _, newValue in
            if !newValue {
                hideAlert()
            }
        }
    }
    
    private func showAlert() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
            scale = 1.0
            opacity = 1.0
            offset = 0
        }
        
        // Auto dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            hideAlert()
        }
    }
    
    private func hideAlert() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0.0
            offset = -30
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}
// MARK: - Alternative Simple Implementation
extension AddSubscriptionView {
    var simpleImprovedAlert: some View {
        VStack(spacing: 20) {
            // Animated checkmark
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundStyle(.white, .green)
                .scaleEffect(viewModel.showingAlert ? 1.0 : 0.3)
                .rotationEffect(.degrees(viewModel.showingAlert ? 0 : -180))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showingAlert)
            
            // Message with typewriter effect
            Text(viewModel.alertMessage)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .scaleEffect(viewModel.showingAlert ? 1.0 : 0.8)
                .opacity(viewModel.showingAlert ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: viewModel.showingAlert)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .scaleEffect(viewModel.showingAlert ? 1.0 : 0.1)
        .opacity(viewModel.showingAlert ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.showingAlert)
        .onAppear {
            if viewModel.showingAlert {
                // Auto dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.showingAlert = false
                    }
                }
            }
        }
    }
}

// MARK: - Modal Header View
struct ModalHeaderView: View {
    let title: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @State private var saveButtonPressed = false
    @State private var cancelButtonPressed = false
    
    var body: some View {
        HStack {
            // Cancel Button
            Button("Cancel") {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                onCancel()
            }
            .font(DesignSystem.Typography.body)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .scaleEffect(cancelButtonPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: cancelButtonPressed)
            .onLongPressGesture(minimumDuration: 0) {
                cancelButtonPressed = true
            } onPressingChanged: { pressing in
                cancelButtonPressed = pressing
            }
            
            Spacer()
            
            // Title
            Text(title)
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Save Button
            Button("Save") {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                onSave()
            }
            .font(DesignSystem.Typography.body)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(DesignSystem.Colors.primary)
            )
            .scaleEffect(saveButtonPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: saveButtonPressed)
            .onLongPressGesture(minimumDuration: 0) {
                saveButtonPressed = true
            } onPressingChanged: { pressing in
                saveButtonPressed = pressing
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(.regularMaterial)
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

