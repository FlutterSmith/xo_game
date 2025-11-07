# XO Game - Test Cases

## Test Execution Tracking
- **Test Start Date**: 2025-11-07
- **Tester**: Claude AI with Chrome MCP
- **Test Environment**: Flutter Web (Chrome Browser)

---

## Test Case 1: Basic 3x3 Game - Player vs Player Win
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Launch the application
2. Wait for splash screen to complete
3. Verify board size is set to 3x3
4. Verify game mode is PvP
5. Click cells to create a winning pattern for X (e.g., top row: 0,1,2)
6. Verify winner message displays correctly
7. Verify winning cells are highlighted
8. Verify game is over (no more moves allowed)

### Expected Results:
- Game board displays correctly
- Moves alternate between X and O
- Winner is detected and displayed as "Winner: X"
- Winning cells are visually highlighted
- Game cannot continue after win

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 2: Board Size Switching (3x3, 4x4, 5x5)
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Start game with default 3x3 board
2. Make 1-2 moves on the board
3. Change board size to 4x4 using dropdown
4. Verify board resets and displays 4x4 grid
5. Make 1-2 moves on 4x4 board
6. Change board size to 5x5
7. Verify board resets and displays 5x5 grid
8. Change back to 3x3
9. Verify board resets correctly

### Expected Results:
- Board size dropdown is visible and functional
- Board correctly displays 9, 16, or 25 cells
- Board resets when size changes
- Previous moves are cleared
- No visual glitches or layout issues

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 3: AI Difficulty Levels (Easy, Medium, Hard)
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Switch to PvC mode (Player vs Computer)
2. Set AI difficulty to "Easy"
3. Play a game and observe AI move patterns
4. Reset game
5. Set AI difficulty to "Medium"
6. Play a game and observe AI behavior
7. Reset game
8. Set AI difficulty to "Hard"
9. Try to win against AI
10. Test "Adaptive" difficulty

### Expected Results:
- Easy AI makes random or simple moves
- Medium AI shows some strategy
- Hard AI is difficult to beat (near-optimal play on 3x3)
- AI responds within reasonable time (<2 seconds)
- AI never makes invalid moves

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 4: Undo/Redo Functionality
**Priority**: Medium
**Status**: ⏳ Not Started

### Test Steps:
1. Start a PvP game
2. Make 3 moves (X, O, X)
3. Click "Undo" button
4. Verify last move is removed
5. Click "Undo" again
6. Verify second-to-last move is removed
7. Click "Redo" button
8. Verify move is restored
9. Make a new move after undo
10. Verify redo stack is cleared
11. Test undo when no moves have been made
12. Test redo when redo stack is empty

### Expected Results:
- Undo removes last move and switches current player
- Redo restores removed move
- Making a new move after undo clears redo stack
- Undo/Redo buttons are disabled when stacks are empty
- Game state is correctly restored

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 5: Game Mode Toggle (PvP vs PvC)
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Start game in PvP mode
2. Make 2 moves (X, O)
3. Click game mode toggle button
4. Verify mode changes to PvC
5. Verify board resets
6. Make a move as X
7. Verify AI (O) responds automatically
8. Toggle back to PvP
9. Verify board resets again

### Expected Results:
- Toggle button displays current mode (PvP or PvC)
- Toggling resets the game board
- In PvC mode, AI moves automatically after player
- In PvP mode, manual input required for both players
- Mode persists during gameplay until toggled

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 6: Draw/Tie Game Detection
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Start a 3x3 PvP game
2. Make moves to fill the board without any winner:
   - X: positions 0, 1, 5
   - O: positions 2, 3, 4
   - X: positions 6, 8
   - O: position 7
3. Verify draw is detected
4. Verify message displays "Draw"
5. Verify no winning cells are highlighted
6. Test draw on 4x4 board
7. Test draw on 5x5 board

### Expected Results:
- Draw is correctly detected when board is full
- Message clearly indicates a draw
- No cells are highlighted
- Game ends properly
- Statistics update correctly (if applicable)

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 7: Navigation Drawer and Screen Navigation
**Priority**: Medium
**Status**: ⏳ Not Started

### Test Steps:
1. Click menu icon (hamburger menu)
2. Verify drawer opens with all menu items
3. Verify player name is displayed
4. Verify win rate is displayed
5. Navigate to "Statistics" screen
6. Verify statistics screen loads correctly
7. Navigate back to home
8. Open drawer and navigate to "Achievements"
9. Navigate to "Game Replays"
10. Navigate to "Game History"
11. Navigate to "How to Play"
12. Navigate to "Settings"
13. Navigate to "About"
14. Return home from each screen

### Expected Results:
- Drawer opens/closes smoothly
- All menu items are visible and clickable
- Each screen loads without errors
- Navigation back to home works from all screens
- No crashes or UI glitches

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 8: Theme Toggle (Light/Dark Mode)
**Priority**: Low
**Status**: ⏳ Not Started

### Test Steps:
1. Observe initial theme (likely dark)
2. Click theme toggle button (brightness icon)
3. Verify theme changes to light mode
4. Check all UI elements for proper visibility
5. Click theme toggle again
6. Verify theme changes back to dark mode
7. Navigate to different screens
8. Verify theme persists across screens
9. Play a game in light mode
10. Play a game in dark mode

### Expected Results:
- Theme toggle button is visible in app bar
- Theme switches smoothly without lag
- All text and UI elements remain visible and readable
- Theme persists across screen navigation
- No visual glitches during theme change

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 9: Reset Game Functionality
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Start a game and make several moves
2. Click the reset button (refresh icon)
3. Verify board is cleared
4. Verify current player resets to X
5. Verify undo/redo stacks are cleared
6. Make moves on reset board
7. Test reset when game is over
8. Test reset in PvC mode
9. Verify AI doesn't move automatically after reset

### Expected Results:
- Reset button is visible and accessible
- Board clears immediately
- Game state fully resets
- Current player is X
- No moves remain in history
- Game is playable after reset

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Test Case 10: 5x5 Board Win Detection (Complex Pattern)
**Priority**: High
**Status**: ⏳ Not Started

### Test Steps:
1. Set board size to 5x5
2. Set mode to PvP
3. Create a winning pattern (5 in a row):
   - Test horizontal win (row 0: positions 0,1,2,3,4)
   - Reset and test vertical win (column 0: positions 0,5,10,15,20)
   - Reset and test diagonal win (positions 0,6,12,18,24)
   - Reset and test anti-diagonal win (positions 4,8,12,16,20)
4. For each pattern, verify winner is detected
5. Verify winning cells are highlighted correctly
6. Test with both X and O as winners

### Expected Results:
- All winning patterns are correctly detected on 5x5 board
- Exactly 5 cells are highlighted as winning pattern
- Correct winner is announced
- Game ends after win is detected
- No false positives or missed wins

### Test Results:
- **Status**:
- **Bugs Found**:
- **Notes**:

---

## Summary Statistics

| Status | Count |
|--------|-------|
| ⏳ Not Started | 10 |
| 🏃 In Progress | 0 |
| ✅ Passed | 0 |
| ❌ Failed | 0 |

---

## Bugs Discovered

### BUG #1: BoardWidget4 Class Name Mismatch (FIXED ✅)
**Severity**: High
**Status**: FIXED (Commit: 5643c89)
**File**: `lib/widgets/board_widget.dart`
**Description**: The file `board_widget.dart` contained class `BoardWidget5` instead of `BoardWidget4`, causing a compilation error when the 4x4 board size was selected.
**Impact**: 4x4 board size would not work at all.
**Fix Applied**:
- Renamed class from `BoardWidget5` to `BoardWidget4`
- Changed import from `cell_widget5.dart` to `cell_widget4.dart`
- Updated `crossAxisCount` from 5 to 4
- Updated `CellWidget5` to `CellWidget4` in itemBuilder

---

## Notes
- Tests will be executed using Chrome DevTools MCP server
- Flutter web application will be tested
- All tests should be repeated after bug fixes
