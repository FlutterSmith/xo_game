# XO Game - Manual Test Cases

**Test Date:** 2025-01-07
**Tester:** Claude Code
**Platform:** Chrome (Flutter Web via MCP)
**App Version:** 1.0.0

---

## Test Case Summary

| # | Test Case | Status | Priority | Notes |
|---|-----------|--------|----------|-------|
| TC-01 | Basic 3x3 Game Flow | ⏳ Pending | High | |
| TC-02 | Board Size Selection (3x3, 4x4, 5x5) | ⏳ Pending | High | |
| TC-03 | AI Difficulty Levels | ⏳ Pending | High | |
| TC-04 | PvP Mode | ⏳ Pending | Medium | |
| TC-05 | Undo/Redo Functionality | ⏳ Pending | Medium | |
| TC-06 | Win Detection & Game End | ⏳ Pending | High | |
| TC-07 | Statistics Tracking | ⏳ Pending | Medium | |
| TC-08 | Achievement Unlocking | ⏳ Pending | Medium | |
| TC-09 | Settings & Theme Toggle | ⏳ Pending | Low | |
| TC-10 | Game Replay System | ⏳ Pending | Low | |

**Legend:**
- ⏳ Pending - Not yet tested
- ✅ Passed - Test passed successfully
- ❌ Failed - Test failed, bug found
- 🔄 In Progress - Currently testing
- 🐛 Bug Fixed - Bug was found and fixed

---

## Detailed Test Cases

### TC-01: Basic 3x3 Game Flow
**Objective:** Verify that a basic 3x3 game can be played from start to finish

**Prerequisites:**
- App is launched and at home screen
- Default board size is 3x3

**Test Steps:**
1. Launch the app
2. Wait for splash screen to complete
3. Verify home screen displays with 3x3 board
4. Select "Player vs Computer" mode
5. Make a move by tapping a cell
6. Wait for AI to make its move
7. Continue until game ends (win/loss/draw)
8. Verify game result is displayed

**Expected Result:**
- Board displays correctly
- Player can make moves
- AI responds with moves
- Win/loss/draw is detected correctly
- Result dialog appears

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-02: Board Size Selection (3x3, 4x4, 5x5)
**Objective:** Verify all three board sizes work correctly

**Prerequisites:**
- App is at home screen

**Test Steps:**
1. Open settings/board size menu
2. Select 3x3 board
3. Verify board displays with 9 cells (3x3)
4. Start new game and play 1-2 moves
5. Select 4x4 board
6. Verify board displays with 16 cells (4x4)
7. Start new game and play 1-2 moves
8. Select 5x5 board
9. Verify board displays with 25 cells (5x5)
10. Start new game and play 1-2 moves

**Expected Result:**
- All three board sizes display correctly
- Cells are properly sized and arranged
- Game logic works for all board sizes
- Win conditions are correct for each size

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-03: AI Difficulty Levels
**Objective:** Verify all AI difficulty levels function correctly

**Prerequisites:**
- App is at home screen
- Mode is "Player vs Computer"

**Test Steps:**
1. Select "Easy" AI difficulty
2. Play a complete game
3. Observe AI behavior (should make random/weak moves)
4. Select "Medium" AI difficulty
5. Play a complete game
6. Observe AI behavior (should be moderately challenging)
7. Select "Hard" AI difficulty
8. Play a complete game
9. Observe AI behavior (should be very difficult to beat)
10. Try "Adaptive" difficulty if available

**Expected Result:**
- Easy AI makes poor strategic moves
- Medium AI shows moderate strategy
- Hard AI is nearly unbeatable (uses minimax)
- Difficulty setting persists between games

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-04: PvP Mode (Player vs Player)
**Objective:** Verify two human players can play against each other

**Prerequisites:**
- App is at home screen

**Test Steps:**
1. Select "Player vs Player" mode
2. Player 1 (X) makes a move
3. Verify turn switches to Player 2 (O)
4. Player 2 makes a move
5. Verify turn switches back to Player 1
6. Continue until game ends
7. Verify correct player wins/draws

**Expected Result:**
- Turns alternate between X and O
- No AI moves are made
- Current player indicator shows correct player
- Win is awarded to correct player
- Game statistics update correctly

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-05: Undo/Redo Functionality
**Objective:** Verify undo and redo buttons work correctly

**Prerequisites:**
- Game is in progress with at least 3 moves made

**Test Steps:**
1. Start a new game (PvP mode recommended)
2. Make 4-5 moves
3. Tap "Undo" button
4. Verify last move is removed
5. Tap "Undo" again
6. Verify previous move is removed
7. Tap "Redo" button
8. Verify move is restored
9. Make a new move after undo
10. Verify redo is no longer available

**Expected Result:**
- Undo removes last move correctly
- Redo restores undone move
- Making a new move clears redo history
- Board state is consistent after undo/redo
- Buttons are disabled when no actions available

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-06: Win Detection & Game End
**Objective:** Verify win conditions are detected correctly for all scenarios

**Prerequisites:**
- App is at home screen

**Test Steps:**
1. Start a new 3x3 game
2. Create a horizontal win (top row: XXX)
3. Verify win is detected
4. Start new game
5. Create a vertical win (left column: XXX)
6. Verify win is detected
7. Start new game
8. Create a diagonal win (top-left to bottom-right: XXX)
9. Verify win is detected
10. Start new game
11. Fill board to create a draw
12. Verify draw is detected

**Expected Result:**
- All win conditions detected immediately
- Game ends when win/draw occurs
- Result dialog shows correct outcome
- No more moves allowed after game ends
- Statistics update correctly

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-07: Statistics Tracking
**Objective:** Verify game statistics are tracked and displayed correctly

**Prerequisites:**
- App is at home screen
- May need to reset statistics first

**Test Steps:**
1. Open statistics screen
2. Note current statistics (games, wins, losses, draws)
3. Return to home and play a game to win
4. Open statistics screen
5. Verify win count increased by 1
6. Verify total games increased by 1
7. Play a game to lose
8. Verify loss count increased by 1
9. Play a game to draw
10. Verify draw count increased by 1
11. Check win rate calculation is correct

**Expected Result:**
- All statistics update in real-time
- Totals are calculated correctly
- Win rate percentage is accurate
- Charts display data correctly
- Statistics persist across app restarts

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-08: Achievement Unlocking
**Objective:** Verify achievements unlock when conditions are met

**Prerequisites:**
- App is at home screen
- May need fresh install or reset achievements

**Test Steps:**
1. Open achievements screen
2. View all locked achievements
3. Play and win first game
4. Verify "First Victory" achievement unlocks
5. Check achievement notification appears
6. Play on different board sizes (3x3, 4x4, 5x5)
7. Verify "Board Explorer" unlocks
8. Win a game on Hard AI
9. Verify "AI Slayer" unlocks
10. Check achievement progress updates

**Expected Result:**
- Achievements unlock when conditions met
- Notification/animation shows on unlock
- Progress bars update correctly
- Achievements screen shows unlocked state
- Achievement data persists

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-09: Settings & Theme Toggle
**Objective:** Verify all settings function correctly

**Prerequisites:**
- App is at home screen

**Test Steps:**
1. Open settings screen
2. Toggle theme from Dark to Light
3. Verify UI changes to light theme
4. Toggle back to Dark theme
5. Enable/disable sound effects
6. Make a move and verify sound plays/doesn't play
7. Enable/disable vibration
8. Make a move and verify vibration occurs/doesn't occur
9. Change default board size
10. Return to home and verify new board size
11. Change AI difficulty default
12. Start game and verify AI uses new difficulty

**Expected Result:**
- Theme changes apply immediately
- Sound setting works correctly
- Vibration setting works correctly
- Default settings persist
- All settings saved across app restarts

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

### TC-10: Game Replay System
**Objective:** Verify game replay functionality works correctly

**Prerequisites:**
- At least one completed game in history

**Test Steps:**
1. Complete a game (any mode/size)
2. Open game history or replays
3. Select a completed game
4. Tap "Play" to start replay
5. Verify moves play automatically
6. Tap "Pause" button
7. Verify replay pauses
8. Use "Step Forward" button
9. Verify next move appears
10. Use "Step Backward" button
11. Verify previous move appears
12. Use slider to jump to move
13. Verify replay jumps correctly

**Expected Result:**
- Replay shows all moves in order
- Play/Pause controls work
- Step forward/backward buttons work
- Slider navigation works
- Replay matches original game exactly
- Can exit replay and return to home

**Status:** ⏳ Pending
**Actual Result:**
**Bugs Found:**

---

## Test Execution Log

### Test Session 1
**Date:** 2025-01-07
**Time:** [Will be filled during testing]
**Environment:** Chrome Browser via MCP

| Time | Test Case | Result | Notes |
|------|-----------|--------|-------|
| | | | |

---

## Bugs Found

### Bug Report Template
**Bug ID:** BUG-XXX
**Test Case:** TC-XX
**Severity:** Critical/High/Medium/Low
**Status:** Open/Fixed/Verified

**Description:**
[What went wrong]

**Steps to Reproduce:**
1.
2.
3.

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happened]

**Fix Applied:**
[Description of fix]

**Verification:**
[How the fix was verified]

---

## Summary & Sign-off

**Total Test Cases:** 10
**Passed:** 0
**Failed:** 0
**Blocked:** 0
**Pass Rate:** 0%

**Overall Assessment:**
[To be filled after testing]

**Recommendations:**
[To be filled after testing]

**Tested By:** Claude Code
**Date:** 2025-01-07
**Signature:** _________________
