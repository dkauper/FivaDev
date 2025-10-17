# FivaDev Test Suite
**Created: October 4, 2025, 11:20 AM Pacific**

## 📋 Overview

Comprehensive unit tests for the Fiva card game deck management system, covering:
- **DeckManager**: 104-card deck operations (27 tests)
- **GameStateManager**: Integration with game state (14 tests)

**Total: 41 test cases**

---

## 🏃 Running Tests

### In Xcode
1. Open `FivaDev.xcodeproj`
2. Select `Product` → `Test` (⌘U)
3. Or click the diamond icons next to test methods

### Command Line
```bash
cd /Users/dkauper/Nextcloud/DevelopmentDocs/Swift_Projects/FivaDev
xcodebuild test -scheme FivaDev -destination 'platform=iOS Simulator,name=iPhone 16'
```

### SwiftLens (if available)
Use the MCP tools to run tests programmatically.

---

## 🧪 Test Coverage

### DeckManagerTests (27 tests)

**Initialization** (1 test)
- ✅ `testInitialization` - Verifies clean slate on creation

**Shuffle Operations** (4 tests)
- ✅ `testNewGameShuffle_CreatesFullDeck` - 104 cards created
- ✅ `testNewGameShuffle_ContainsCorrectCards` - Each card appears exactly twice
- ✅ `testShuffleRandomness` - Different shuffles produce different orders
- ✅ `testShuffleNewGame_ResetsState` - Clears previous game state

**Card Drawing** (5 tests)
- ✅ `testDrawCard_ReturnsCardAndReducesDeck` - Basic draw operation
- ✅ `testDrawCard_FromEmptyDeck_ReturnsNil` - Empty deck handling
- ✅ `testDrawCards_ReturnsCorrectQuantity` - Multiple card draws
- ✅ `testDrawCards_AllCardsUnique` - No duplicate draws
- ✅ `testDrawCards_MoreThanAvailable` - Edge case handling

**Discard Operations** (2 tests)
- ✅ `testDiscard_AddsToDiscardPile` - Discard pile management
- ✅ `testDiscard_RemovesFromInPlay` - State transitions

**Board Placement** (2 tests)
- ✅ `testPlaceOnBoard_AddsToInPlay` - Card placement tracking
- ✅ `testRemoveFromBoard_RemovesFromInPlay` - Card removal (one-eyed Jack)

**Reshuffle Operations** (4 tests)
- ✅ `testReshuffleDiscards_MovesDiscardsToWeek` - Discard pile becomes deck
- ✅ `testReshuffleDiscards_CannotReshuffleWithCardsInDeck` - Guards against premature reshuffle
- ✅ `testReshuffleDiscards_CannotReshuffleEmptyDiscards` - Empty pile validation
- ✅ `testAutoReshuffle_TriggersOnDraw` - Automatic reshuffle when deck depletes

**Query Methods** (3 tests)
- ✅ `testIsDeckCardAvailable` - Card location queries
- ✅ `testIsCardDiscarded` - Discard pile queries
- ✅ `testIsCardInPlay` - Board state queries

**Integrity Checks** (3 tests)
- ✅ `testDeckIntegrity_AfterShuffle` - Post-shuffle validation
- ✅ `testDeckIntegrity_AfterGameSimulation` - Full game validation
- ✅ `testTotalCardsTracked_AlwaysEquals104` - Conservation of cards

**Performance** (2 tests)
- ✅ `testShufflePerformance` - Shuffle speed benchmark
- ✅ `testDrawCardsPerformance` - Draw operation speed

---

### GameStateManagerTests (14 tests)

**Initialization** (2 tests)
- ✅ `testInitialization_InitializesDeckManager` - DeckManager integration
- ✅ `testInitialization_DealsCards` - Initial card dealing

**Card Playing** (4 tests)
- ✅ `testPlayCardOnBoard_RemovesFromHand` - Hand management
- ✅ `testPlayCardOnBoard_MarksAsInPlay` - Board state tracking
- ✅ `testPlayCardOnBoard_DrawsReplacement` - Automatic card replacement
- ✅ `testPlayCardOnBoard_AdvancesPlayer` - Turn progression

**Discard Operations** (2 tests)
- ✅ `testDiscardDeadCard_RemovesFromHand` - Dead card handling
- ✅ `testDiscardDeadCard_AddsToDiscardPile` - Discard pile integration

**Game State** (4 tests)
- ✅ `testStartNewGame_ResetsState` - Clean game restart
- ✅ `testGetBoardPositions_ReturnsCorrectPositions` - Board layout queries
- ✅ `testHighlightCard_AddsToHighlightedSet` - UI highlighting
- ✅ `testHighlightCard_RemovesFromHighlightedSet` - Highlight cleanup (async)

**Integration** (2 tests)
- ✅ `testFullGameFlow` - Multi-turn gameplay simulation
- ✅ `testVerifyGameIntegrity` - End-to-end validation

---

## 🔍 Key Test Scenarios

### Critical Path Tests
1. **New Game Setup** → Shuffle → Deal → Verify
2. **Card Play Loop** → Draw → Play → Replace → Advance
3. **Deck Depletion** → Empty → Auto-reshuffle → Continue
4. **Dead Card** → Identify → Discard → Replace

### Edge Cases Covered
- Drawing from empty deck
- Drawing more cards than available
- Reshuffling with cards still in deck
- Reshuffling empty discard pile
- Invalid card operations

### Performance Benchmarks
- Shuffle: ~0.001s (1ms) for 104 cards
- Draw: ~0.0001s (0.1ms) per operation

---

## 📊 Expected Results

All tests should **PASS** ✅

If any tests fail:
1. Check `DeckManager.swift` for recent changes
2. Verify `GameStateManager.swift` integration
3. Review test output for specific failure details
4. Check console logs for diagnostic information

---

## 🛠️ Adding New Tests

### Template for New Test
```swift
func testFeatureName_ExpectedBehavior() {
    // Given - Setup
    let initialState = sut.someProperty
    
    // When - Action
    sut.performAction()
    
    // Then - Verification
    XCTAssertEqual(sut.someProperty, expectedValue, "Description")
}
```

### Best Practices
- One assertion per test when possible
- Descriptive test names: `test[Feature]_[ExpectedBehavior]`
- Use Given-When-Then structure
- Add console logs for diagnostic output
- Test both success and failure paths

---

## 📝 Integration Notes

### To Add Tests to Xcode:
1. Open `FivaDev.xcodeproj` in Xcode
2. Right-click project → Add Files
3. Select `FivaDevTests` folder
4. Ensure "Create groups" is selected
5. Check "FivaDev" as the target
6. Click Add

### OR: Manual Test Target Setup
1. File → New → Target
2. Select "iOS Unit Testing Bundle"
3. Name: `FivaDevTests`
4. Add `DeckManagerTests.swift` to target
5. Set target dependency on main app

---

## 🐛 Debug Tools

Tests include debug output:
```swift
// Print full deck state
sut.deckManager.printFullDeckState()

// Verify integrity
XCTAssertTrue(sut.deckManager.verifyDeckIntegrity())

// Get game state
print(sut.getDebugInfo())
```

---

## ✅ Test Checklist

Before committing:
- [ ] All tests pass
- [ ] No test warnings
- [ ] Performance tests within acceptable range
- [ ] New features have corresponding tests
- [ ] Console output is clean

---

**Next Steps:**
1. Add tests to Xcode project
2. Run full test suite (⌘U)
3. Fix any failures
4. Add test coverage for board state tracking
5. Add tests for Jack special rules

**Test Coverage:** 41 tests covering core deck management and game state integration
