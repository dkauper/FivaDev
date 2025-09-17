# Fiva Game - iOS/macOS Board Game

A SwiftUI implementation of the classic Sequence board game, renamed to "Fiva" for trademark reasons. This project creates a 2D board game experience that runs on iOS, iPadOS, macOS, and tvOS.

## Project Status

✅ **COMPLETED**: 2D Board Game Structure Conversion
- Removed 3D RealityKit components
- Implemented proper 2D SwiftUI architecture  
- Created game board with locked orientation as specified
- Added proper MVVM architecture with clean separation of concerns
- Integrated official Sequence game board layout

## Game Features

- **10x10 Game Board**: Proper grid layout with 1:1.5 aspect ratio elements
- **Official Board Layout**: Uses the authentic Sequence game card placement
- **Locked Orientation**: Board elements maintain position relative to device orientation
- **Player Hand Management**: Expandable/collapsible card overlay with glass effects
- **Game State Management**: Complete turn-based gameplay with sequence detection
- **Multi-Platform**: Supports iOS, iPadOS, macOS, and tvOS

## Architecture

The project follows MVVM (Model-View-ViewModel) architecture:

```
FivaDev/
├── Models/
│   ├── GameModels.swift      # Core data structures (Card, Player, BoardSpace, etc.)
│   ├── GameState.swift       # Main game state management
│   └── GameLogic.swift       # Game rules engine and board layout
├── ViewModels/
│   └── GameViewModel.swift   # Main game controller and UI state
├── Views/
│   ├── GameView.swift        # Main game container and setup
│   ├── GameBoardView.swift   # Game board grid implementation  
│   ├── PlayerHandView.swift  # Player hand overlay with cards
│   └── GameInfoView.swift    # Game status and discard pile
├── Utilities/
│   └── Constants.swift       # Game configuration and constants
└── Assets.xcassets/          # Playing card SVGs and chip graphics
```

## Key Implementation Details

### Board Layout
- **GameBoard**: Rectangle that maintains orientation relationship with device
- **GameGrid**: 10x10 grid locked in position within GameBoard
- **Grid Elements**: Numbered 0-99, flowing left-to-right, top-to-bottom
- **Background**: #B7E4CC as specified in requirements

### Card Management  
- **Two Standard Decks**: 104 cards total (52 × 2)
- **Special Cards**: Two-eyed Jacks (wild), One-eyed Jacks (remove opponent chips)
- **Dead Card Rule**: Can discard when both board positions are occupied
- **Hand Size**: Varies by player count (2-12 players supported)

### Game Rules
- **Objective**: Form sequences of 5 chips in a row
- **Corner Spaces**: Free for all players (represented by Joker/★)
- **Win Conditions**: 
  - 2-3 players: Need 1 sequence to win
  - 4+ players: Need 2 sequences to win

### UI Features
- **Hover Effects**: 50% size increase on macOS hover (as specified)
- **Glass Effects**: Applied to player hand cards
- **Visual Feedback**: Highlights valid moves, completed sequences
- **Responsive Layout**: Adapts to device orientation changes

## Development Status

### ✅ Completed
- [x] Core game models and data structures
- [x] Official Sequence board layout implementation
- [x] Game state management with turn-based play
- [x] MVVM architecture setup
- [x] 2D board visualization with proper grid
- [x] Player hand management with expansion/collapse
- [x] Card selection and move validation
- [x] Sequence detection algorithm
- [x] Win condition checking
- [x] Dead card detection and discard logic
- [x] Multi-platform UI adaptations
- [x] Git repository setup and GitHub integration

### 🔄 In Progress
- [ ] Enhanced animations and transitions
- [ ] Card art integration from existing SVG assets  
- [ ] Sound effects and haptic feedback

### 📋 Future Enhancements
- [ ] Local multiplayer via Multipeer Connectivity
- [ ] Online multiplayer via Game Center
- [ ] AI player implementation
- [ ] Game replay and statistics
- [ ] Accessibility features
- [ ] Additional visual themes

## Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/dkauper/FivaDev.git
   cd FivaDev
   ```

2. **Open in Xcode**: Open `FivaDev.xcodeproj` in Xcode 26+

3. **Build and Run**: Select your target platform and run the app

## Technical Requirements

- **Xcode**: Version 26+
- **iOS**: 26.0+
- **macOS**: 15.4+
- **tvOS**: 26.0+
- **Swift**: 6.0+

## Git Repository

This project is properly linked to GitHub at: https://github.com/dkauper/FivaDev

The repository includes:
- Complete SwiftUI source code
- SVG playing card assets (52 cards + jokers)
- Chip graphics for game pieces
- Comprehensive documentation
- Project configuration files

---

## License

This project is developed for educational and personal use. The Sequence game is a trademark of Jax Ltd.
