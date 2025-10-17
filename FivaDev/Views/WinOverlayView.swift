//
//  WinOverlayView.swift
//  FivaDev
//
//  Created by Doron Kauper on 10/16/25.
//  Updated: October 17, 2025, 9:45 AM Pacific - Added confetti celebration effect
//

import SwiftUI

struct WinOverlayView: View {
    let winningColor: PlayerColor
    let fivaCount: Int
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -10
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // 🎊 Confetti celebration effect
            if showConfetti {
                ConfettiView(
                    bodyWidth: bodyWidth,
                    bodyHeight: bodyHeight,
                    colors: confettiColors
                )
                .zIndex(2)
            }
            
            VStack(spacing: bodyHeight * 0.03) {
                // Trophy icon
                Text("🏆")
                    .font(.system(size: min(bodyWidth, bodyHeight) * 0.15))
                    .rotationEffect(.degrees(rotation))
                
                // Winner announcement
                Text("\(winningColor.displayName) Team Wins!")
                    .font(.system(size: min(bodyWidth, bodyHeight) * 0.06, weight: .bold))
                    .foregroundColor(winningColor.color)
                    .shadow(color: winningColor.color.opacity(0.5), radius: 10, x: 0, y: 0)
                
                // Winning chip
                Image(winningColor.chipImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(bodyWidth, bodyHeight) * 0.2)
                    .shadow(color: winningColor.color.opacity(0.5), radius: 15, x: 0, y: 0)
                
                // FIVA count
                Text("\(fivaCount) FIVA\(fivaCount > 1 ? "s" : "") Completed!")
                    .font(.system(size: min(bodyWidth, bodyHeight) * 0.04, weight: .semibold))
                    .foregroundColor(.white)
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text("New Game")
                        .font(.system(size: min(bodyWidth, bodyHeight) * 0.035, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, bodyWidth * 0.08)
                        .padding(.vertical, bodyHeight * 0.02)
                        .background(winningColor.color)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.top, bodyHeight * 0.02)
            }
            .padding(bodyWidth * 0.05)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(winningColor.color, lineWidth: 4)
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .zIndex(1)
        }
        .onAppear {
            // Animate entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
            
            // Trigger confetti slightly delayed for dramatic effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
    
    /// Colors for confetti based on winning team
    private var confettiColors: [Color] {
        // Include winning team color plus festive colors
        [
            winningColor.color,
            .yellow,
            .orange,
            .pink,
            .purple,
            .mint,
            .cyan
        ]
    }
}
