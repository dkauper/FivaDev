//
//  PlayerHandView.swift
//  FivaDev
//
//  Enhanced with component-based card rendering synchronized with GameGrid
//  Created by Doron Kauper on 9/18/25.
//  Updated: September 29, 2025, 10:15 AM PDT
//

import SwiftUI

struct PlayerHandView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    let layoutConstants: GlobalLayoutConstants
    let orientation: AppOrientation
    
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var hoveredCardIndex: Int? = nil
    @State private var touchedCardIndex: Int? = nil
    
    // Use the enhanced layout system
    private var playerHandConstants: PlayerHandLayoutConstants {
        PlayerHandLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    // Card layout configuration
    private var cardLayoutConstants: PlayerHandCardLayoutConstants {
        PlayerHandCardLayoutConstants.current(
            for: DeviceType.current,
            orientation: orientation
        )
    }
    
    // Sample cards for the current player (will be replaced with actual game state)
    private var playerCards: [String] {
        return gameStateManager.currentPlayerCards
    }
    
    // CRITICAL: Calculate GameGrid card dimensions to match hand cards
    private var gameGridCardDimensions: (width: CGFloat, height: CGFloat) {
        // Calculate GameBoard dimensions (same as GameBoard.swift)
        let topPadding = layoutConstants.gameBoardTopPaddingValue(bodyHeight)
        let leftPadding = layoutConstants.gameBoardLeftPaddingValue(bodyWidth)
        let bottomPadding = layoutConstants.gameBoardBottomPaddingValue(bodyHeight)
        let rightPadding = layoutConstants.gameBoardRightPaddingValue(bodyWidth)
        
        let gameBoardWidth = bodyWidth - leftPadding - rightPadding
        let gameBoardHeight = bodyHeight - topPadding - bottomPadding
        
        // Calculate GameGrid card dimensions (same as GameGrid.swift)
        let gridPaddingPercent: CGFloat = 0.02
        let cardSpacingPercent: CGFloat = 0.008
        let gridSize: CGFloat = 10
        
        let gridPadding = min(gameBoardWidth, gameBoardHeight) * gridPaddingPercent
        let availableWidth = gameBoardWidth - (gridPadding * 2)
        let availableHeight = gameBoardHeight - (gridPadding * 2)
        
        let spacing = min(availableWidth, availableHeight) * cardSpacingPercent
        let totalSpacingWidth = spacing * (gridSize - 1)
        let totalSpacingHeight = spacing * (gridSize - 1)
        
        let netAvailableWidth = availableWidth - totalSpacingWidth
        let netAvailableHeight = availableHeight - totalSpacingHeight
        
        let cardWidth = netAvailableWidth / gridSize
        let cardHeight = netAvailableHeight / gridSize
        
        return (width: cardWidth, height: cardHeight)
    }
    
    var body: some View {
        let topPadding = playerHandConstants.topValue(bodyHeight)
        let bottomPadding = playerHandConstants.bottomValue(bodyHeight)
        let leftPadding = playerHandConstants.leftValue(bodyWidth)
        let rightPadding = playerHandConstants.rightValue(bodyWidth)
        
        let handWidth = playerHandConstants.overlayWidth(bodyWidth)
        let handHeight = playerHandConstants.overlayHeight(bodyHeight)
        
        VStack(spacing: 0) {
            // Top padding
            Spacer()
                .frame(height: topPadding)
            
            HStack(spacing: 0) {
                // Left padding
                Spacer()
                    .frame(width: leftPadding)
                
                // Player hand overlay
                playerHandOverlay(width: handWidth, height: handHeight)
                
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
    
    private func playerHandOverlay(width: CGFloat, height: CGFloat) -> some View {
        // Use configurable overlay padding
        let overlayPadding = cardLayoutConstants.overlayPadding(overlayWidth: width, overlayHeight: height)
        
        return cardsGridContainer(
            availableWidth: width - (overlayPadding * 2),
            availableHeight: height - (overlayPadding * 2)
        )
        .padding(overlayPadding)
        .background(
            RoundedRectangle(cornerRadius: cardLayoutConstants.overlayCornerRadius(overlayWidth: width))
                .fill(.ultraThinMaterial)
                .stroke(.red.opacity(0.6), lineWidth: 2)
        )
        .frame(width: width, height: height)
    }
    
    private func cardsGridContainer(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        fixedSizeCardsGrid(
            availableWidth: availableWidth,
            availableHeight: availableHeight
        )
    }
    
    private func fixedSizeCardsGrid(availableWidth: CGFloat, availableHeight: CGFloat) -> some View {
        // Calculate card dimensions to fit within the overlay
        let cardCount = CGFloat(playerCards.count)
        let spacing = cardLayoutConstants.cardSpacing(availableWidth: availableWidth, columns: playerCards.count)
        
        // Determine layout direction based on overlay dimensions
        // When width > height: horizontal layout (cards in a row)
        // When height > width: vertical layout (cards in a column)
        let useHorizontalLayout = availableWidth > availableHeight
        
        if useHorizontalLayout {
            // HORIZONTAL LAYOUT: Cards flow left to right
            let totalSpacing = spacing * (cardCount - 1)
            let availableCardWidth = availableWidth - totalSpacing
            let availableCardHeight = availableHeight
            
            let cardWidth = availableCardWidth / cardCount
            let cardHeight = availableCardHeight
            
            return AnyView(
                HStack(spacing: spacing) {
                    ForEach(Array(playerCards.enumerated()), id: \.offset) { index, card in
                        playerCardView(
                            cardName: card,
                            width: cardWidth,
                            height: cardHeight,
                            index: index
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else {
            // VERTICAL LAYOUT: Cards stack top to bottom
            let totalSpacing = spacing * (cardCount - 1)
            let availableCardHeight = availableHeight - totalSpacing
            let availableCardWidth = availableWidth
            
            let cardHeight = availableCardHeight / cardCount
            let cardWidth = availableCardWidth
            
            return AnyView(
                VStack(spacing: spacing) {
                    ForEach(Array(playerCards.enumerated()), id: \.offset) { index, card in
                        playerCardView(
                            cardName: card,
                            width: cardWidth,
                            height: cardHeight,
                            index: index
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
    }
    
    private func playerCardView(cardName: String, width: CGFloat, height: CGFloat, index: Int) -> some View {
        let isHovered = hoveredCardIndex == index
        let isTouched = touchedCardIndex == index
        let isActive = isHovered || isTouched
        
        // Parse card data from card name
        let cardData = CardData.parse(from: cardName)
        
        return ZStack {
            // Card background with border - always vertical
            RoundedRectangle(cornerRadius: cardLayoutConstants.cardCornerRadius(cardWidth: width))
                .fill(Color.white.opacity(0.1))
                .stroke(Color.green.opacity(1), lineWidth: 2)
            
            // Component-based card rendering - always portrait orientation
            ComponentBasedPlayingCard(
                cardData: cardData,
                width: width,
                height: height,
                cardOrientation: .portrait,  // Cards in hand always portrait
                cardInternalPadding: cardLayoutConstants.cardInternalPadding
            )
            .padding(cardLayoutConstants.cardInternalPadding)
        }
        .frame(width: width, height: height)
        .glassEffect()
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .overlay(
            RoundedRectangle(cornerRadius: cardLayoutConstants.cardCornerRadius(cardWidth: width))
                .stroke(Color.blue.opacity(isActive ? 0.4 : 0), lineWidth: 1)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        )
        #if !os(tvOS)
        .onHover { isHovering in
            hoveredCardIndex = isHovering ? index : nil
            
            Task { @MainActor in
                gameStateManager.highlightCard(cardName, highlight: isHovering)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if touchedCardIndex != index {
                        touchedCardIndex = index
                        Task { @MainActor in
                            gameStateManager.highlightCard(cardName, highlight: true)
                        }
                    }
                }
                .onEnded { _ in
                    touchedCardIndex = nil
                    Task { @MainActor in
                        gameStateManager.highlightCard(cardName, highlight: false)
                    }
                }
        )
        #else
        .focusable(true) { isFocused in
            hoveredCardIndex = isFocused ? index : nil
            Task { @MainActor in
                gameStateManager.highlightCard(cardName, highlight: isFocused)
            }
        }
        #endif
        .onTapGesture {
            playCard(at: index)
        }
        .onChange(of: isActive) { _, newValue in
            #if canImport(UIKit) && !os(tvOS)
            if newValue {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            #endif
        }
    }
    
    private func playCard(at index: Int) {
        let cardName = playerCards[index]
        print("Playing card: \(cardName) at index \(index)")
        
        withAnimation(.spring(duration: 0.3)) {
            // Future: Add card playing logic
        }
    }
}

// MARK: - Card Data Structure (same as GameGridElement)
private struct CardData {
    let suit: Suit?
    let rank: Rank?
    let isJoker: Bool
    let jokerColor: JokerColor?
    
    enum Suit: String, CaseIterable {
        case hearts = "H", diamonds = "D", clubs = "C", spades = "S"
        
        var symbol: String {
            switch self {
            case .hearts: return "♥"
            case .diamonds: return "♦"
            case .clubs: return "♣"
            case .spades: return "♠"
            }
        }
        
        var color: Color {
            switch self {
            case .hearts, .diamonds: return .red
            case .clubs, .spades: return .black
            }
        }
        
        var assetName: String {
            switch self {
            case .hearts: return "Hearts"
            case .diamonds: return "Diamonds"
            case .clubs: return "Clubs"
            case .spades: return "Spades"
            }
        }
    }
    
    enum Rank: String, CaseIterable {
        case two = "2", three = "3", four = "4", five = "5", six = "6", seven = "7", eight = "8", nine = "9", ten = "10"
        case jack = "J", queen = "Q", king = "K", ace = "A"
        
        var isFaceCard: Bool {
            return [.jack, .queen, .king].contains(self)
        }
        
        var isAce: Bool {
            return self == .ace
        }
        
        var pipPattern: String? {
            switch self {
            case .two: return "pip_pattern_2"
            case .three: return "pip_pattern_3"
            case .four: return "pip_pattern_4"
            case .five: return "pip_pattern_5"
            case .six: return "pip_pattern_6"
            case .seven: return "pip_pattern_7"
            case .eight: return "pip_pattern_8"
            case .nine: return "pip_pattern_9"
            case .ten: return "pip_pattern_10"
            default: return nil
            }
        }
    }
    
    enum JokerColor {
        case red, black
    }
    
    static func parse(from cardName: String) -> CardData {
        if cardName == "RedJoker" {
            return CardData(suit: nil, rank: nil, isJoker: true, jokerColor: .red)
        } else if cardName == "BlackJoker" {
            return CardData(suit: nil, rank: nil, isJoker: true, jokerColor: .black)
        }
        
        let suitString = String(cardName.suffix(1))
        let rankString = String(cardName.dropLast(1))
        
        let suit = Suit(rawValue: suitString)
        let rank = Rank(rawValue: rankString)
        
        return CardData(suit: suit, rank: rank, isJoker: false, jokerColor: nil)
    }
}

// MARK: - Component-Based Card Percentages for Player Hand
// Always use portrait percentages since cards in hand are always vertical
private struct HandCardPercentages {
    let centerRectangleTopPadding: CGFloat = 0.15
    let centerRectangleBottomPadding: CGFloat = 0.15
    let centerRectangleSidePadding: CGFloat = 0.03
    
    let cornerPipTopPadding: CGFloat = 0.05
    let cornerPipBottomPadding: CGFloat = 0.05
    let cornerPipSidePadding: CGFloat = 0.13
    
    let cornerRankHeight: CGFloat = 0.34
    let cornerSuitHeight: CGFloat = 0.25
    let cornerSuitTopPadding: CGFloat = 0.33
    let cornerSuitBottomPadding: CGFloat = 0.35
    
    let faceCardScaleFactor: CGFloat = 0.98
    let aceScaleFactor: CGFloat = 0.7
    let pipPatternScaleFactor: CGFloat = 0.90
}

// MARK: - Component-Based Playing Card View
private struct ComponentBasedPlayingCard: View {
    let cardData: CardData
    let width: CGFloat
    let height: CGFloat
    let cardOrientation: AppOrientation
    let cardInternalPadding: CGFloat
    
    private let percentages = HandCardPercentages()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.05)
                .fill(Color.white)
                .stroke(Color.black, lineWidth: 1)
            
            if cardData.isJoker {
                jokerContent
            } else {
                regularCardContent
            }
        }
        .frame(width: width, height: height)
    }
    
    @ViewBuilder
    private var jokerContent: some View {
        if let jokerColor = cardData.jokerColor {
            let imageName = jokerColor == .red ? "JokerColor" : "JokerBW"
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(cardInternalPadding)
        }
    }
    
    @ViewBuilder
    private var regularCardContent: some View {
        if let suit = cardData.suit, let rank = cardData.rank {
            ZStack {
                cornerPips(suit: suit, rank: rank)
                centerContent(suit: suit, rank: rank)
            }
        }
    }
    
    @ViewBuilder
    private func cornerPips(suit: CardData.Suit, rank: CardData.Rank) -> some View {
        // TOP-LEFT CORNER
        Text(rank.rawValue)
            .font(.system(size: height * percentages.cornerRankHeight * 0.6, weight: .bold))
            .foregroundColor(suit.color)
            .position(
                x: width * percentages.cornerPipSidePadding,
                y: height * percentages.cornerPipTopPadding + (height * percentages.cornerRankHeight * 0.3)
            )
        
        Text(suit.symbol)
            .font(.system(size: width * percentages.cornerSuitHeight * 0.8))
            .foregroundColor(suit.color)
            .position(
                x: width * percentages.cornerPipSidePadding,
                y: height * percentages.cornerSuitTopPadding
            )
        
        // BOTTOM-RIGHT CORNER (rotated 180°)
        Text(suit.symbol)
            .font(.system(size: width * percentages.cornerSuitHeight * 0.8))
            .foregroundColor(suit.color)
            .rotationEffect(.degrees(180))
            .position(
                x: width * (1 - percentages.cornerPipSidePadding),
                y: height * (1 - percentages.cornerSuitBottomPadding)
            )
        
        Text(rank.rawValue)
            .font(.system(size: height * percentages.cornerRankHeight * 0.6, weight: .bold))
            .foregroundColor(suit.color)
            .rotationEffect(.degrees(180))
            .position(
                x: width * (1 - percentages.cornerPipSidePadding),
                y: height * (1 - percentages.cornerPipBottomPadding - (percentages.cornerRankHeight * 0.3))
            )
    }
    
    @ViewBuilder
    private func centerContent(suit: CardData.Suit, rank: CardData.Rank) -> some View {
        let centerWidth = width * (1 - 2 * percentages.centerRectangleSidePadding)
        let centerHeight = height * (1 - percentages.centerRectangleTopPadding - percentages.centerRectangleBottomPadding)
        
        Rectangle()
            .fill(Color.clear)
            .frame(width: centerWidth, height: centerHeight)
            .overlay(
                Group {
                    if rank.isFaceCard {
                        faceCardContent(suit: suit, rank: rank, centerWidth: centerWidth, centerHeight: centerHeight)
                    } else if rank.isAce {
                        aceContent(suit: suit, centerWidth: centerWidth, centerHeight: centerHeight)
                    } else {
                        pipContent(suit: suit, rank: rank, centerWidth: centerWidth, centerHeight: centerHeight)
                    }
                }
            )
            .position(x: width * 0.5, y: height * 0.5)
    }
    
    @ViewBuilder
    private func faceCardContent(suit: CardData.Suit, rank: CardData.Rank, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        let scaledWidth = centerWidth * percentages.faceCardScaleFactor
        let scaledHeight = centerHeight * percentages.faceCardScaleFactor
        
        let faceImageName = "\(rank == .jack ? "Jack" : rank == .queen ? "Queen" : "King")\(suit.assetName)"
        
        Image(faceImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: scaledWidth, height: scaledHeight)
    }
    
    @ViewBuilder
    private func aceContent(suit: CardData.Suit, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        let pipSize = min(centerWidth, centerHeight) * percentages.aceScaleFactor
        
        Text(suit.symbol)
            .font(.system(size: pipSize))
            .foregroundColor(suit.color)
            .position(x: centerWidth * 0.5, y: centerHeight * 0.5)
    }
    
    @ViewBuilder
    private func pipContent(suit: CardData.Suit, rank: CardData.Rank, centerWidth: CGFloat, centerHeight: CGFloat) -> some View {
        if let pipPattern = rank.pipPattern {
            let scaledWidth = centerWidth * percentages.pipPatternScaleFactor
            let scaledHeight = centerHeight * percentages.pipPatternScaleFactor
            
            Image(pipPattern)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: scaledWidth, height: scaledHeight)
                .foregroundColor(suit.color)
        } else {
            let fallbackSize = min(centerWidth, centerHeight) * percentages.pipPatternScaleFactor * 0.4
            
            Text(rank.rawValue)
                .font(.system(size: fallbackSize, weight: .bold))
                .foregroundColor(suit.color)
        }
    }
}

// MARK: - Preview Support
#Preview("iPhone Portrait") {
    GeometryReader { geometry in
        let deviceType = DeviceType.iPhone
        let orientation = AppOrientation.portrait
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("iPad Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.iPad
        let orientation: AppOrientation = .landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}

#Preview("Mac Landscape") {
    GeometryReader { geometry in
        let deviceType = DeviceType.mac
        let orientation: AppOrientation = .landscape
        let layoutConstants = GlobalLayoutConstants.current(for: deviceType, orientation: orientation)
        let bodyHeight = layoutConstants.bodyHeightValue(geometry.size.height)
        let bodyWidth = layoutConstants.bodyWidthValue(geometry.size.width)
        
        PlayerHandView(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            layoutConstants: layoutConstants,
            orientation: orientation
        )
        .environmentObject(GameStateManager())
    }
    .background(Color(hex: "B7E4CC"))
}
