//
//  ConfettiView.swift
//  FivaDev
//
//  Created: October 17, 2025, 9:40 AM Pacific
//  Native SwiftUI confetti particle system for win celebration
//

import SwiftUI

/// Individual confetti piece with physics
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var rotation: Double
    var velocity: CGPoint
    var angularVelocity: Double
    var scale: CGFloat
}

/// Confetti particle system view
struct ConfettiView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let colors: [Color]
    
    @State private var pieces: [ConfettiPiece] = []
    @State private var isAnimating = false
    
    private let pieceCount = 150
    private let gravity: CGFloat = 0.3
    private let friction: CGFloat = 0.98
    
    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                ConfettiShape()
                    .fill(piece.color)
                    .frame(width: 10, height: 20)
                    .scaleEffect(piece.scale)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(x: piece.x, y: piece.y)
            }
        }
        .frame(width: bodyWidth, height: bodyHeight)
        .allowsHitTesting(false)
        .onAppear {
            startConfetti()
        }
    }
    
    private func startConfetti() {
        // Create initial confetti pieces at top center
        pieces = (0..<pieceCount).map { _ in
            ConfettiPiece(
                x: bodyWidth / 2 + CGFloat.random(in: -50...50),
                y: -20,
                color: colors.randomElement() ?? .blue,
                rotation: Double.random(in: 0...360),
                velocity: CGPoint(
                    x: CGFloat.random(in: -8...8),
                    y: CGFloat.random(in: -3...3)
                ),
                angularVelocity: Double.random(in: -15...15),
                scale: CGFloat.random(in: 0.6...1.2)
            )
        }
        
        isAnimating = true
        animateConfetti()
    }
    
    private func animateConfetti() {
        guard isAnimating else { return }
        
        // Update physics for each piece
        for index in pieces.indices {
            // Apply gravity
            pieces[index].velocity.y += gravity
            
            // Apply friction
            pieces[index].velocity.x *= friction
            pieces[index].velocity.y *= friction
            
            // Update position
            pieces[index].x += pieces[index].velocity.x
            pieces[index].y += pieces[index].velocity.y
            
            // Update rotation
            pieces[index].rotation += pieces[index].angularVelocity
            
            // Slow down rotation
            pieces[index].angularVelocity *= friction
            
            // Fade out as pieces fall
            let fadeThreshold = bodyHeight * 0.7
            if pieces[index].y > fadeThreshold {
                let fadeAmount = (pieces[index].y - fadeThreshold) / (bodyHeight * 0.3)
                pieces[index].scale = max(0, 1.2 - fadeAmount)
            }
        }
        
        // Remove pieces that are off screen
        pieces.removeAll { piece in
            piece.y > bodyHeight + 50 || piece.scale <= 0
        }
        
        // Continue animation
        if !pieces.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                animateConfetti()
            }
        }
    }
}

/// Simple confetti shape (rectangle with rounded corners)
struct ConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cornerRadius: CGFloat = 2
        return RoundedRectangle(cornerRadius: cornerRadius)
            .path(in: rect)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        ConfettiView(
            bodyWidth: 400,
            bodyHeight: 600,
            colors: [.red, .blue, .green, .yellow, .orange, .purple]
        )
    }
}
