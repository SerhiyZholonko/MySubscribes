//
//  CustomTabView.swift
//  MySubscribes
//
//  Created by Claude on 03.07.2025.
//

import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false
    @State private var waveOffset: CGFloat = 0
    @State private var buttonScales: [CGFloat] = [1.0, 1.0, 1.0]
    @Namespace private var waveNamespace
    
    let tabs = [
        TabItem(icon: "list.bullet.rectangle", selectedIcon: "list.bullet.rectangle.fill", title: "Subscriptions"),
        TabItem(icon: "calendar.badge.checkmark", selectedIcon: "calendar.badge.checkmark", title: "Calendar"),
        TabItem(icon: "chart.bar.xaxis", selectedIcon: "chart.bar.xaxis", title: "Analytics")
    ]
    
    var body: some View {
        ZStack {
            // Paper texture background
            PaperBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab content with paper effect
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
                        .scaleEffect(selectedTab == index ? 1 : 0.96)
                        .rotationEffect(.degrees(selectedTab == index ? 0 : Double(index - selectedTab) * 2))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedTab)
                    }
                }
                
                // Wave-style tab bar
                WaveTabBar(
                    selectedTab: $selectedTab,
                    tabs: tabs,
                    waveOffset: $waveOffset,
                    buttonScales: $buttonScales,
                    namespace: waveNamespace
                )
            }
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
        .onAppear {
            startWaveAnimation()
        }
    }
    
    func startWaveAnimation() {
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            waveOffset = 360
        }
    }
}

// MARK: - Paper Background
struct PaperBackground: View {
    var body: some View {
        ZStack {
            // Base paper color - Adaptive
            Color(light: Color(red: 0.98, green: 0.97, blue: 0.95), dark: Color(red: 0.08, green: 0.07, blue: 0.05))
            
            // Paper texture
            Canvas { context, size in
                // Create subtle paper texture with dots
                for _ in 0..<200 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let dotSize = CGFloat.random(in: 0.5...1.5)
                    
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                        with: .color(Color(light: Color.brown.opacity(0.1), dark: Color.white.opacity(0.05)))
                    )
                }
                
                // Add some light paper lines
                for i in stride(from: 0, to: Int(size.height), by: 40) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: CGFloat(i)))
                    path.addLine(to: CGPoint(x: size.width, y: CGFloat(i)))
                    context.stroke(path, with: .color(Color(light: Color.gray.opacity(0.05), dark: Color.white.opacity(0.02))), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - Wave Tab Bar
struct WaveTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @Binding var waveOffset: CGFloat
    @Binding var buttonScales: [CGFloat]
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            // Wave background - Adaptive colors
            WaveShape(offset: waveOffset, amplitude: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(light: Color.white.opacity(0.9), dark: Color.black.opacity(0.8)),
                            Color(light: Color.gray.opacity(0.1), dark: Color.gray.opacity(0.3))
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .shadow(color: Color(light: Color.black.opacity(0.1), dark: Color.white.opacity(0.05)), radius: 5, x: 0, y: -2)
            
            // Small waves on top - Adaptive colors
            WaveShape(offset: waveOffset * 1.5, amplitude: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(light: Color.white.opacity(0.7), dark: Color.black.opacity(0.6)),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 60)
                .offset(y: -20)
            
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    WaveTabButton(
                        tab: tab,
                        index: index,
                        isSelected: selectedTab == index,
                        scale: buttonScales[index],
                        namespace: namespace,
                        action: {
                            // Ripple effect
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                buttonScales[index] = 1.3
                                selectedTab = index
                            }
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
                                buttonScales[index] = 1.0
                            }
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 30)
            .offset(y: -10)
        }
        .frame(height: 100)
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    let offset: CGFloat
    let amplitude: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let wavelength = width / 2
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset / 180 * .pi))
            let y = amplitude * sine + height / 2
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Wave Tab Button
struct WaveTabButton: View {
    let tab: TabItem
    let index: Int
    let isSelected: Bool
    let scale: CGFloat
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Button(action: {
            action()
            
            // Rotation effect
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                rotationAngle += 360
            }
        }) {
            VStack(spacing: 8) {
                // Icon without circle background - Simple adaptive colors
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotationAngle))
                    .shadow(color: isSelected ? .primary.opacity(0.2) : Color.clear, radius: 2, x: 1, y: 1)
                    .frame(width: 50, height: 50)
                
                // Handwritten-style text - Simple adaptive colors
                Text(tab.title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .shadow(color: isSelected ? .primary.opacity(0.2) : Color.clear, radius: 1, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
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

// MARK: - Alternative: Sketch Tab View
struct SketchTabView: View {
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false
    @State private var sketchLines: [SketchLine] = []
    @Namespace private var sketchNamespace
    
    let tabs = [
        TabItem(icon: "list.bullet.rectangle", selectedIcon: "list.bullet.rectangle.fill", title: "Subscriptions"),
        TabItem(icon: "calendar.badge.checkmark", selectedIcon: "calendar.badge.checkmark", title: "Calendar"),
        TabItem(icon: "chart.bar.xaxis", selectedIcon: "chart.bar.xaxis", title: "Analytics")
    ]
    
    var body: some View {
        ZStack {
            // Sketch paper background
            Color(red: 0.99, green: 0.98, blue: 0.96)
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
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                
                // Sketch-style tab bar
                SketchTabBar(
                    selectedTab: $selectedTab,
                    tabs: tabs,
                    sketchLines: $sketchLines,
                    namespace: sketchNamespace
                )
            }
            
            // Animated sketch lines
            SketchOverlay(lines: sketchLines)
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
    }
}

// MARK: - Sketch Tab Bar
struct SketchTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @Binding var sketchLines: [SketchLine]
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                SketchTabButton(
                    tab: tab,
                    isSelected: selectedTab == index,
                    namespace: namespace,
                    action: {
                        generateSketchLines()
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            // Hand-drawn rectangle
            SketchRectangle()
                .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                .background(Color.white.opacity(0.8))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    func generateSketchLines() {
        sketchLines.removeAll()
        for _ in 0..<5 {
            let line = SketchLine(
                start: CGPoint(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                    y: CGFloat.random(in: 100...200)
                ),
                end: CGPoint(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                    y: CGFloat.random(in: 100...200)
                ),
                opacity: Double.random(in: 0.1...0.3)
            )
            sketchLines.append(line)
        }
        
        // Animate lines appearance and disappearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                for i in 0..<sketchLines.count {
                    sketchLines[i].opacity = 0
                }
            }
        }
    }
}

// MARK: - Sketch Tab Button
struct SketchTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var wiggle: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Hand-drawn circle
                    if isSelected {
                        SketchCircle()
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                            .frame(width: 50, height: 50)
                            .overlay(
                                SketchCircle()
                                    .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                            )
                            .matchedGeometryEffect(id: "sketchCircle", in: namespace)
                    }
                    
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : Color.gray)
                        .offset(x: wiggle, y: wiggle)
                }
                .frame(width: 50, height: 50)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : Color.gray)
                    .offset(x: wiggle / 2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isSelected {
                withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                    wiggle = CGFloat.random(in: -0.5...0.5)
                }
            }
        }
    }
}

// MARK: - Sketch Shapes
struct SketchRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Hand-drawn rectangle with slight imperfections
        let jitter: CGFloat = 2
        
        path.move(to: CGPoint(
            x: rect.minX + CGFloat.random(in: -jitter...jitter),
            y: rect.minY + CGFloat.random(in: -jitter...jitter)
        ))
        
        path.addLine(to: CGPoint(
            x: rect.maxX + CGFloat.random(in: -jitter...jitter),
            y: rect.minY + CGFloat.random(in: -jitter...jitter)
        ))
        
        path.addLine(to: CGPoint(
            x: rect.maxX + CGFloat.random(in: -jitter...jitter),
            y: rect.maxY + CGFloat.random(in: -jitter...jitter)
        ))
        
        path.addLine(to: CGPoint(
            x: rect.minX + CGFloat.random(in: -jitter...jitter),
            y: rect.maxY + CGFloat.random(in: -jitter...jitter)
        ))
        
        path.closeSubpath()
        return path
    }
}

struct SketchCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Hand-drawn circle with imperfections
        for i in 0...360 {
            let angle = Double(i) * .pi / 180
            let jitter = CGFloat.random(in: -1...1)
            let x = center.x + (radius + jitter) * cos(angle)
            let y = center.y + (radius + jitter) * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// MARK: - Sketch Overlay
struct SketchOverlay: View {
    let lines: [SketchLine]
    
    var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.move(to: line.start)
                path.addLine(to: line.end)
                context.stroke(path, with: .color(Color.gray.opacity(line.opacity)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Data Models
struct TabItem {
    let icon: String
    let selectedIcon: String
    let title: String
}

struct SketchLine {
    let start: CGPoint
    let end: CGPoint
    var opacity: Double
}

#Preview {
    CustomTabView()
}