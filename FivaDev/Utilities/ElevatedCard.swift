//
//  ElevatedCard.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/21/25.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A reusable card component that can be highlighted with elevation effects
struct ElevatedCard<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    let isHighlighted: Bool
    let cornerRadius: CGFloat
    let highlightScale: CGFloat
    let strokeColor: Color
    let strokeWidth: CGFloat
    let highlightStrokeWidth: CGFloat
    let enableGlassEffect: Bool
    let enableHapticFeedback: Bool
    let zIndex: Double
    let highlightZIndex: Double
    
    @ViewBuilder let content: Content
    
    init(
        width: CGFloat,
        height: CGFloat,
        isHighlighted: Bool,
        cornerRadius: CGFloat = 6,
        highlightScale: CGFloat = 1.5,
        strokeColor: Color = Color(hex: "009051"),
        strokeWidth: CGFloat = 4,
        highlightStrokeWidth: CGFloat = 6,
        enableGlassEffect: Bool = true,
        enableHapticFeedback: Bool = true,
        zIndex: Double = 0,
        highlightZIndex: Double = 10000,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.height = height
        self.isHighlighted = isHighlighted
        self.cornerRadius = cornerRadius
        self.highlightScale = highlightScale
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.highlightStrokeWidth = highlightStrokeWidth
        self.enableGlassEffect = enableGlassEffect
        self.enableHapticFeedback = enableHapticFeedback
        self.zIndex = zIndex
        self.highlightZIndex = highlightZIndex
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isHighlighted {
                highlightedCardView
            } else {
                normalCardView
            }
        }
        .onChange(of: isHighlighted) { _, newValue in
            if enableHapticFeedback && newValue {
                #if canImport(UIKit) && !os(tvOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                #endif
            }
        }
    }
    
    private var normalCardView: some View {
        cardContent
            .frame(width: width, height: height)
            .scaleEffect(1.0)
            .zIndex(zIndex)
    }
    
    private var highlightedCardView: some View {
        ZStack {
            // Create elevated shadow effect
            cardContent
                .blur(radius: 8)
                .offset(x: 4, y: 4)
                .opacity(0.3)
                .scaleEffect(highlightScale)
            
            // Main highlighted card
            cardContent
                .scaleEffect(highlightScale)
        }
        .frame(width: width, height: height)
        .zIndex(highlightZIndex)
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1), value: true)
    }
    
    private var cardContent: some View {
        ZStack {
            // Card background with rounded corners
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .stroke(strokeColor, lineWidth: isHighlighted ? highlightStrokeWidth : strokeWidth)
            
            // Glass effect overlay when highlighted
            if isHighlighted && enableGlassEffect {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.white.opacity(0.4), lineWidth: 2)
                    )
            }
            
            // Content
            content
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 2))
                .padding(isHighlighted ? 4 : 0)
        }
    }
}

/// Convenience initializer for image-based cards
extension ElevatedCard {
    /// Create an ElevatedCard with an image
    init(
        imageName: String,
        width: CGFloat,
        height: CGFloat,
        isHighlighted: Bool,
        cornerRadius: CGFloat = 6,
        highlightScale: CGFloat = 1.5,
        strokeColor: Color = Color(hex: "009051"),
        strokeWidth: CGFloat = 4,
        highlightStrokeWidth: CGFloat = 6,
        enableGlassEffect: Bool = true,
        enableHapticFeedback: Bool = true,
        zIndex: Double = 0,
        highlightZIndex: Double = 10000
    ) where Content == AnyView {
        self.init(
            width: width,
            height: height,
            isHighlighted: isHighlighted,
            cornerRadius: cornerRadius,
            highlightScale: highlightScale,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            highlightStrokeWidth: highlightStrokeWidth,
            enableGlassEffect: enableGlassEffect,
            enableHapticFeedback: enableHapticFeedback,
            zIndex: zIndex,
            highlightZIndex: highlightZIndex
        ) {
            AnyView(
                Group {
                    #if canImport(UIKit)
                    if let cardImage = UIImage(named: imageName) {
                        Image(uiImage: cardImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "questionmark.square")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                    #else
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    #endif
                }
            )
        }
    }
}

#Preview("Normal Card") {
    ElevatedCard(
        imageName: "AC",
        width: 60,
        height: 90,
        isHighlighted: false
    )
    .padding()
}

#Preview("Highlighted Card") {
    ElevatedCard(
        imageName: "AC",
        width: 60,
        height: 90,
        isHighlighted: true
    )
    .padding()
}

#Preview("Custom Content") {
    ElevatedCard(
        width: 80,
        height: 120,
        isHighlighted: true,
        highlightScale: 1.3,
        strokeColor: .blue
    ) {
        VStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.title)
            Text("Custom")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
    .padding()
}
