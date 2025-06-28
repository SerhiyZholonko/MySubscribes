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
    
    var body: some View {
        VStack {
            ASHeaderView(
                onSave: {
                    hideKeyboard() // Dismiss keyboard before saving
                    viewModel.saveSubscription()
                },
                onCancel: {
                    hideKeyboard() // Dismiss keyboard before canceling
                    dismiss()
                }
            )
            
            ZStack(alignment: .top) {
                Color(.blue)
                    .opacity(0.1)
                ScrollView {
                    ServiceNameView(serviceNameText: $viewModel.serviceNameText)
                    MonthlyCostView(monthlyCostText: $viewModel.monthlyCostText)
                    BillingPeriodView(selectedPeriod: $viewModel.selectedPeriod)
                    NextPaymentDateView(nextPaymentDate: $viewModel.nextPaymentDate)
                }
            }
        }
        .dismissKeyboardOnTap() // Apply keyboard dismissal
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
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
