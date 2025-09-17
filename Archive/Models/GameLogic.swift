//
//  GameLogic.swift
//  FivaDev
//
//  Created by Claude on 9/16/25.
//

import Foundation

struct GameLogic {
    
    // MARK: - Official Sequence Board Layout
    
    /// The official Sequence game board layout as a 10x10 grid (positions 0-99)
    /// Each card (except Jacks) appears exactly twice on the board
    /// Corners are free spaces (represented as nil)
    static let officialBoardLayout: [Card?] = [
        // Row 0 (positions 0-9)
        nil,                                          // 0: Corner (free space)
        Card(suit: .spades, rank: .two),              // 1: 2S
        Card(suit: .diamonds, rank: .three),          // 2: 3D
        Card(suit: .hearts, rank: .three),            // 3: 3H
        Card(suit: .clubs, rank: .three),             // 4: 3C
        Card(suit: .spades, rank: .three),            // 5: 3S
        Card(suit: .diamonds, rank: .four),           // 6: 4D
        Card(suit: .hearts, rank: .four),             // 7: 4H
        Card(suit: .clubs, rank: .four),              // 8: 4C
        nil,                                          // 9: Corner (free space)
        
        // Row 1 (positions 10-19)
        Card(suit: .clubs, rank: .six),               // 10: 6C
        Card(suit: .clubs, rank: .five),              // 11: 5C
        Card(suit: .diamonds, rank: .four),           // 12: 4D
        Card(suit: .clubs, rank: .two),               // 13: 2C
        Card(suit: .hearts, rank: .ace),              // 14: AH
        Card(suit: .diamonds, rank: .king),           // 15: KD
        Card(suit: .clubs, rank: .queen),             // 16: QC
        Card(suit: .hearts, rank: .ten),              // 17: 10H
        Card(suit: .spades, rank: .eight),            // 18: 8S
        Card(suit: .spades, rank: .four),             // 19: 4S
        
        // Row 2 (positions 20-29)
        Card(suit: .hearts, rank: .seven),            // 20: 7H
        Card(suit: .spades, rank: .six),              // 21: 6S
        Card(suit: .diamonds, rank: .five),           // 22: 5D
        Card(suit: .hearts, rank: .two),              // 23: 2H
        Card(suit: .diamonds, rank: .three),          // 24: 3D
        Card(suit: .clubs, rank: .king),              // 25: KC
        Card(suit: .diamonds, rank: .ace),            // 26: AD
        Card(suit: .spades, rank: .nine),             // 27: 9S
        Card(suit: .clubs, rank: .seven),             // 28: 7C
        Card(suit: .diamonds, rank: .five),           // 29: 5D
        
        // Row 3 (positions 30-39)
        Card(suit: .clubs, rank: .eight),             // 30: 8C
        Card(suit: .hearts, rank: .five),             // 31: 5H
        Card(suit: .clubs, rank: .four),              // 32: 4C
        Card(suit: .diamonds, rank: .ace),            // 33: AD
        Card(suit: .hearts, rank: .nine),             // 34: 9H
        Card(suit: .hearts, rank: .eight),            // 35: 8H
        Card(suit: .diamonds, rank: .seven),          // 36: 7D
        Card(suit: .hearts, rank: .six),              // 37: 6H
        Card(suit: .diamonds, rank: .two),            // 38: 2D
        Card(suit: .hearts, rank: .six),              // 39: 6H
        
        // Row 4 (positions 40-49)
        Card(suit: .clubs, rank: .nine),              // 40: 9C
        Card(suit: .spades, rank: .four),             // 41: 4S
        Card(suit: .spades, rank: .five),             // 42: 5S
        Card(suit: .hearts, rank: .king),             // 43: KH
        Card(suit: .hearts, rank: .three),            // 44: 3H
        Card(suit: .diamonds, rank: .two),            // 45: 2D
        Card(suit: .spades, rank: .seven),            // 46: 7S
        Card(suit: .diamonds, rank: .eight),          // 47: 8D
        Card(suit: .clubs, rank: .three),             // 48: 3C
        Card(suit: .diamonds, rank: .six),            // 49: 6D
        
        // Row 5 (positions 50-59)
        Card(suit: .hearts, rank: .ten),              // 50: 10H
        Card(suit: .hearts, rank: .queen),            // 51: QH
        Card(suit: .diamonds, rank: .queen),          // 52: QD
        Card(suit: .diamonds, rank: .ten),            // 53: 10D
        Card(suit: .hearts, rank: .five),             // 54: 5H
        Card(suit: .clubs, rank: .two),               // 55: 2C
        Card(suit: .spades, rank: .three),            // 56: 3S
        Card(suit: .clubs, rank: .king),              // 57: KC
        Card(suit: .spades, rank: .king),             // 58: KS
        Card(suit: .clubs, rank: .ten),               // 59: 10C
        
        // Row 6 (positions 60-69)
        Card(suit: .spades, rank: .nine),             // 60: 9S
        Card(suit: .hearts, rank: .ace),              // 61: AH
        Card(suit: .spades, rank: .ace),              // 62: AS
        Card(suit: .diamonds, rank: .king),           // 63: KD
        Card(suit: .clubs, rank: .ace),               // 64: AC
        Card(suit: .spades, rank: .two),              // 65: 2S
        Card(suit: .hearts, rank: .four),             // 66: 4H
        Card(suit: .diamonds, rank: .nine),           // 67: 9D
        Card(suit: .clubs, rank: .queen),             // 68: QC
        Card(suit: .spades, rank: .ten),              // 69: 10S
        
        // Row 7 (positions 70-79)
        Card(suit: .diamonds, rank: .eight),          // 70: 8D
        Card(suit: .clubs, rank: .seven),             // 71: 7C
        Card(suit: .spades, rank: .six),              // 72: 6S
        Card(suit: .clubs, rank: .five),              // 73: 5C
        Card(suit: .diamonds, rank: .four),           // 74: 4D
        Card(suit: .hearts, rank: .seven),            // 75: 7H
        Card(suit: .hearts, rank: .eight),            // 76: 8H
        Card(suit: .clubs, rank: .nine),              // 77: 9C
        Card(suit: .spades, rank: .queen),            // 78: QS
        Card(suit: .diamonds, rank: .seven),          // 79: 7D
        
        // Row 8 (positions 80-89)
        Card(suit: .clubs, rank: .six),               // 80: 6C
        Card(suit: .spades, rank: .five),             // 81: 5S
        Card(suit: .diamonds, rank: .two),            // 82: 2D
        Card(suit: .hearts, rank: .queen),            // 83: QH
        Card(suit: .diamonds, rank: .queen),          // 84: QD
        Card(suit: .diamonds, rank: .ten),            // 85: 10D
        Card(suit: .spades, rank: .king),             // 86: KS
        Card(suit: .clubs, rank: .ace),               // 87: AC
        Card(suit: .spades, rank: .ace),              // 88: AS
        Card(suit: .hearts, rank: .nine),             // 89: 9H
        
        // Row 9 (positions 90-99)
        nil,                                          // 90: Corner (free space)
        Card(suit: .spades, rank: .eight),            // 91: 8S
        Card(suit: .spades, rank: .seven),            // 92: 7S
        Card(suit: .diamonds, rank: .six),            // 93: 6D
        Card(suit: .clubs, rank: .eight),             // 94: 8C
        Card(suit: .hearts, rank: .two),              // 95: 2H
        Card(suit: .clubs, rank: .three),             // 96: 3C
        Card(suit: .spades, rank: .three),            // 97: 3S
        Card(suit: .hearts, rank: .three),            // 98: 3H
        nil                                           // 99: Corner (free space)
    ]
    
    // MARK: - Sequence Detection
    
    /// Detects all possible sequences starting from a given position
    static func detectSequencesFrom(
        position: Int,
        boardSpaces: [BoardSpace],
        playerID: UUID
    ) -> [GameSequence] {
        
        var sequences: [GameSequence] = []
        let row = position / GameConstants.boardSize
        let col = position % GameConstants.boardSize
        
        // Check all four directions
        for direction in GameRules.sequenceDirections {
            if let sequence = checkSequenceInDirection(
                from: (row, col),
                direction: direction,
                boardSpaces: boardSpaces,
                playerID: playerID
            ) {
                sequences.append(sequence)
            }
        }
        
        return sequences
    }
    
    /// Checks for a sequence in a specific direction
    private static func checkSequenceInDirection(
        from start: (row: Int, col: Int),
        direction: (row: Int, col: Int),
        boardSpaces: [BoardSpace],
        playerID: UUID
    ) -> GameSequence? {
        
        var positions: [Int] = []
        
        // Find the start of the sequence by going backwards
        var currentRow = start.row
        var currentCol = start.col
        
        // Go backwards to find the beginning of the sequence
        while isValidPosition(row: currentRow - direction.row, col: currentCol - direction.col) {
            let backPosition = (currentRow - direction.row) * GameConstants.boardSize + (currentCol - direction.col)
            if hasPlayerChipOrCorner(at: backPosition, boardSpaces: boardSpaces, playerID: playerID) {
                currentRow -= direction.row
                currentCol -= direction.col
            } else {
                break
            }
        }
        
        // Now collect all consecutive positions in the forward direction
        while isValidPosition(row: currentRow, col: currentCol) {
            let pos = currentRow * GameConstants.boardSize + currentCol
            if hasPlayerChipOrCorner(at: pos, boardSpaces: boardSpaces, playerID: playerID) {
                positions.append(pos)
                currentRow += direction.row
                currentCol += direction.col
            } else {
                break
            }
        }
        
        // Need at least 5 for a valid sequence
        guard positions.count >= GameRules.sequenceLength else { return nil }
        
        // Take only the first 5 positions for the sequence
        let sequencePositions = Array(positions.prefix(GameRules.sequenceLength))
        
        let sequenceDirection: GameSequence.SequenceDirection = {
            if direction.row == 0 { return .horizontal }
            if direction.col == 0 { return .vertical }
            if direction.row == direction.col { return .diagonalDown }
            return .diagonalUp
        }()
        
        return GameSequence(
            positions: sequencePositions,
            playerID: playerID,
            direction: sequenceDirection
        )
    }
    
    // MARK: - Helper Functions
    
    /// Checks if a position is valid on the board
    private static func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < GameConstants.boardSize && col >= 0 && col < GameConstants.boardSize
    }
    
    /// Checks if a position has the player's chip or is a corner space
    private static func hasPlayerChipOrCorner(
        at position: Int,
        boardSpaces: [BoardSpace],
        playerID: UUID
    ) -> Bool {
        guard position >= 0 && position < boardSpaces.count else { return false }
        
        let boardSpace = boardSpaces[position]
        
        // Corner spaces count as any player's chip
        if GameRules.cornerPositions.contains(position) {
            return true
        }
        
        // Check if player has a chip here
        return boardSpace.chip?.playerID == playerID
    }
    
    // MARK: - Move Validation
    
    /// Validates if a card can be played at a specific position
    static func isValidMove(
        card: Card,
        position: Int,
        boardSpaces: [BoardSpace],
        currentPlayer: Player?
    ) -> Bool {
        guard position >= 0 && position < boardSpaces.count else { return false }
        guard let currentPlayer = currentPlayer else { return false }
        
        let boardSpace = boardSpaces[position]
        
        // Two-eyed Jack can be played anywhere that's empty
        if card.isTwoEyedJack {
            return boardSpace.chip == nil
        }
        
        // One-eyed Jack can remove opponent chips (not in completed sequences)
        if card.isOneEyedJack {
            guard let chip = boardSpace.chip else { return false }
            return chip.playerID != currentPlayer.id && !boardSpace.isPartOfSequence
        }
        
        // Regular cards must match the board position and be empty
        guard let boardCard = boardSpace.position.card else { return false }
        return card.suit == boardCard.suit && 
               card.rank == boardCard.rank && 
               boardSpace.chip == nil
    }
    
    // MARK: - Dead Card Detection
    
    /// Checks if a card is "dead" (both board positions occupied)
    static func isDeadCard(_ card: Card, boardSpaces: [BoardSpace]) -> Bool {
        guard !card.isJack else { return false } // Jacks are never dead
        
        let matchingPositions = findMatchingPositions(for: card, in: boardSpaces)
        let occupiedCount = matchingPositions.filter { position in
            boardSpaces[position].chip != nil
        }.count
        
        return occupiedCount >= 2 // Both positions occupied
    }
    
    /// Finds all board positions that match a given card
    static func findMatchingPositions(for card: Card, in boardSpaces: [BoardSpace]) -> [Int] {
        guard !card.isJack else { return [] }
        
        return boardSpaces.enumerated().compactMap { index, space in
            guard let boardCard = space.position.card else { return nil }
            return (boardCard.suit == card.suit && boardCard.rank == card.rank) ? index : nil
        }
    }
    
    // MARK: - Game Setup
    
    /// Creates the initial board spaces with the official layout
    static func createBoardSpaces() -> [BoardSpace] {
        var boardSpaces: [BoardSpace] = []
        
        for i in 0..<GameConstants.totalPositions {
            let position = BoardPosition(id: i, card: officialBoardLayout[i])
            let boardSpace = BoardSpace(position: position)
            boardSpaces.append(boardSpace)
        }
        
        return boardSpaces
    }
    
    /// Creates and shuffles two standard decks
    static func createGameDeck() -> [Card] {
        let singleDeck = createStandardDeck()
        var gameDeck = singleDeck + singleDeck // Two decks
        gameDeck.shuffle()
        return gameDeck
    }
    
    /// Creates a single standard 52-card deck
    private static func createStandardDeck() -> [Card] {
        var deck: [Card] = []
        
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        
        return deck
    }
}
