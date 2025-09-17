# Archived Files - FivaDev Project

**Archive Date:** September 16, 2025
**Reason:** Transitioning from full game implementation to skeleton 2D game board structure

## Archived Components

### Views/
- **GameView.swift** - Main game container view (replaced by Header/Body structure)
- **GameBoardView.swift** - Original game board implementation (replaced by GameBoard.swift)
- **PlayerHandView.swift** - Player hand overlay functionality (removed in skeleton)
- **GameInfoView.swift** - Game information display (removed in skeleton)

### ViewModels/
- **GameViewModel.swift** - Main game state management and logic controller

### Models/
- **GameModels.swift** - Card, Player, and Board data structures
- **GameState.swift** - Core game state management
- **GameLogic.swift** - Game rules engine and validation

### Utilities/
- **Constants.swift** - Game constants and configuration values

### Other/
- **SpinComponent.swift.old** - Legacy component (already obsolete)

## Notes

These files contain the full Fiva game implementation including:
- Complete game logic and rules
- Player management
- Card handling
- 5-in-a-row detection
- Turn management
- UI overlays for player hands

## Restoration

To restore any of these components:
1. Copy the file(s) back to the appropriate FivaDev/ directory
2. Add file references back to the Xcode project
3. Update imports and dependencies as needed

## Assets Preserved

The following assets were preserved in the main project:
- PlayingCards/ asset catalog with all 52 card images + Jokers
- Card back designs
- Chip graphics

---
*Archived as part of skeleton structure refactoring - Doron Kauper*
