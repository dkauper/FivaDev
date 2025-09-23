//
//  DiscardOverlayView.swift
//  FivaDev
//
//  Created by Doron Kauper on 9/21/25.
//

import SwiftUI

struct DiscardOverlayView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let discardConstants: DiscardOverlayLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var hoveredLastCard: Bool = false
    @State private var touchedLastCard: Bool = false
    
    var body: some View {
        let topPadding = discardConstants.discardOverlayTopValue(bodyHeight)
        let bottomPadding = discardConstants.discardOverlayBottomValue(bodyHeight)
        let leftPadding = discardConstants.discardOverlayLeftValue(bodyWidth)
        let rightPadding = discardConstants.discardOverlayRightValue(bodyWidth)
        
        let overlayWidth = bodyWidth - leftPadding - rightPadding
        let overlayHeight = bodyHeight - topPadding - bottomPadding
        
        VStack(spacing: 0) {
            // Top padding
            Spacer()
                .frame(height: topPadding)
            
            HStack(spacing: 0) {
                // Left padding
                Spacer()
                    .frame(width: leftPadding)
                
                // Discard overlay
                discardOverlay(width: overlayWidth, height: overlayHeight)
                
                // Right padding
                Spacer()
                    .frame(width: rightPadding)
            }
            
            // Bottom padding
            Spacer()
                .frame(height: bottomPadding)
        }
        .frame(width: bodyWidth, height: bodyHeight)
    }
    
    private func discardOverlay(width: CGFloat, height: CGFloat) -> some View {
        let overlayPadding: CGFloat = 8
        
        return discardGridContainer(
            availableWidth: width - (overlayPadding * 2),
            availableHeight: height - (overlayPadding * 2)
        )
        .padding(overlayPadding)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.blue.opacity(0.6), lineWidth: 2) // Blue border to distinguish from player hand
        )
        .frame(width: width, height: height)
    }
    
    private func discardGridContainer(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Most recent discard card
            discardCardView(
                cardName: gameStateManager.mostRecentDiscard,
                width: availableWidth * 0.8,
                height: availableHeight * 0.35
            )
            
            // Current player name
            currentPlayerView(
                width: availableWidth,
                height: availableHeight * 0.25
            )
            
            // Last card played
            lastCardPlayedView(
                cardName: gameStateManager.lastCardPlayed,
                width: availableWidth * 0.8,
                height: availableHeight * 0.35
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func discardCardView(cardName: String?, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .stroke(Color.gray.opacity(0.8), lineWidth: 2)
            
            if let cardName = cardName {
                // Card image
                Image(cardName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(1)
            } else {
                // Placeholder when no card is discarded
                Text("No Discard")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: width, height: height)
        .glassEffect()
    }
    
    private func currentPlayerView(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue.opacity(0.2))
                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
            
            VStack(spacing: 2) {
                Text("Current Player")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(gameStateManager.currentPlayerName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .frame(width: width, height: height)
    }
    
    private func lastCardPlayedView(cardName: String?, width: CGFloat, height: CGFloat) -> some View {
        let isActive = hoveredLastCard || touchedLastCard
        
        return ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .stroke(Color.green.opacity(0.8), lineWidth: 2)
            
            if let cardName = cardName {
                // Card image
                Image(cardName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(1)
            } else {
                // Placeholder when no card has been played
                Text("No Card Played")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        #if !os(tvOS)
        .onHover { isHovering in
            hoveredLastCard = isHovering
            
            if let cardName = cardName {
                Task { @MainActor in
                    gameStateManager.highlightCard(cardName, highlight: isHovering)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !touchedLastCard {
                        touchedLastCard = true
                        if let cardName = cardName {
                            Task { @MainActor in
                                gameStateManager.highlightCard(cardName, highlight: true)
                            }
                        }
                    }
                }
                .onEnded { _ in
                    touchedLastCard = false
                    if let cardName = cardName {
                        Task { @MainActor in
                            gameStateManager.highlightCard(cardName, highlight: false)
                        }
                    }
                }
        )
        #else
        // tvOS: Use focus-based interaction
        .focusable(true) { isFocused in
            hoveredLastCard = isFocused
            if let cardName = cardName {
                Task { @MainActor in
                    gameStateManager.highlightCard(cardName, highlight: isFocused)
                }
            }
        }
        #endif
        .onTapGesture {
            // Handle card interaction if needed
            if let cardName = cardName {
                print("Tapped last played card: \(cardName)")
            }
        }
        .onChange(of: isActive) { _, newValue in
            // Add haptic feedback on iOS when card becomes active
            #if canImport(UIKit) && !os(tvOS)
            if newValue {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            #endif
        }
    }
}

#Preview("Portrait") {
    GeometryReader { geometry in
        let deviceType = DeviceType.current
        let orientation = AppOrientation.current(geometry: geometry)
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let discardConstants = DiscardOverlayLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        DiscardOverlayView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            discardConstants: discardConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "eabf90"))
}

#Preview("Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.current
        let orientation: AppOrientation = .landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let discardConstants = DiscardOverlayLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        DiscardOverlayView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            discardConstants: discardConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "eabf90"))
}
