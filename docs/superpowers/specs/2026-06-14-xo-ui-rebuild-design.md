# XO Game — UI Rebuild Design Spec

**Date:** 2026-06-14
**Status:** Approved (design); pending spec review → implementation plan
**Authoring team (personas):** Senior Software Engineer · Senior UI/UX Designer · Expert XO gamer / game-feel specialist

---

## 1. Problem & framing

The app's UI is described as "a giant flaming mess." A three-lens survey of the actual code found that the
**mess is concentrated in the presentation + structure layer, while the gameplay/logic core is sound (rated 9/10 on
game feel).** Therefore the rebuild **preserves the proven logic and game feel** and **rebuilds the UI, structure, and
a small set of genuine gameplay bugs.**

### Confirmed findings (grounded in code)
- **No enforced design system:** centralized theme exists (`theme_cubit.dart`) but is bypassed by ~800 hardcoded color
  uses; 8 font families declared, ~3 used; `pick_side_screen.dart` references a font by file path (won't render).
- **Severe widget duplication:** `board_widget{,3,5}.dart` ~98% identical (differ only by `crossAxisCount`);
  `cell_widget{,4,5}.dart` differ only by `markSize` (60/50/40). ~400 lines of copy-paste. Button styles reinvented 5+
  times; stat card implemented 3 times. `AdvancedNeumorphicButton` defined but unused.
- **IA flaws:** orphaned/unreachable `pick_side_screen.dart`; duplicate `/replays` + `/replay-viewer` routes;
  History and Replay Viewer screens overlap; player-side selection split from Game Setup. 5 screens exceed 500 lines.
- **Gameplay bugs / half-baked features:** "Your Turn" badge always shown (wrong in PvP/PvC); latent double-AI-move
  race via `Future.delayed` + fragile `nextPlayer == 'O'` check; "Impossible" difficulty functionally identical to
  Hard; Timed mode incomplete (`// TODO: Phase 4`, AI ignores timeout); missing achievement-unlock sound.
- **Strengths to preserve:** minimax AI (3×3 Hard mathematically unbeatable), juicy mark-draw animation, cell tap
  scale, win-line glow, confetti, tuned vibration patterns, correct win detection for 3/4/5.

---

## 2. Approved decisions

| # | Decision | Choice |
|---|----------|--------|
| 1 | Scope | **Full rework** — visual rebuild + structural surgery + gameplay bug fixes; preserve logic/AI |
| 2 | Visual identity | **Disciplined neon-arcade** — keep violet→pink→teal DNA, enforced via one strict design system |
| 3 | Half-baked features | **Fix both** — real distinct "Impossible" tier; finish Timed mode properly |
| 4 | Fonts / i18n | **Trim to 2 fonts (Poppins + Inter), drop unused fonts and the unused Arabic/RTL pretense** (English-only) |
| 5 | Conflict resolution | **Approved design governs scope; pasted prompt governs discipline.** BLoC **event/state contracts stay stable**; only buggy internals are fixed |

---

## 3. Design system (single source of truth)

New `lib/theme/` package. **Every** screen/widget references it — zero hardcoded colors/sizes in screens.

- **`app_colors.dart`** — neon-arcade palette: violet `#8B5CF6`, pink `#EC4899`, teal `#16F2B3`; semantic tokens
  (win / lose / draw, X-mark, O-mark, surfaces, on-surface) for **light + dark**.
- **`app_typography.dart`** — **2 families only:** `Poppins` (display/headings), `Inter` (body). Defined type scale.
- **`app_spacing.dart`** — one scale: 4 / 8 / 12 / 16 / 24 / 32 / 48.
- **`app_motion.dart`** — shared durations + curves so all motion feels related.
- **`app_theme.dart`** — builds light & dark `ThemeData` from the tokens. **`ThemeCubit` keeps its public API**; it just
  sources colors/text from this package instead of inline literals.
- **pubspec/assets:** remove Almarai, NunitoSans, InterDisplay, Manrope, Raleway, SFProDisplay font declarations and
  their asset files (keep Poppins + Inter). *Pubspec change → STOP-and-confirm gate per discipline rules.*

---

## 4. Reusable component kit (`lib/widgets/common/`)

Eliminates duplication; everything below replaces ad-hoc copies.

- **`GameBoard`** — one parameterized board (size 3/4/5) replacing `board_widget{,3,5}.dart`.
- **`GameCell`** — one cell with `markSize` param replacing `cell_widget{,4,5}.dart`; preserves tap-scale + win-glow.
- **`AnimatedMark`** — keep the existing draw-on X/O stroke animation (refactor into the kit).
- **`NeonButton`** — primary / secondary / danger variants; replaces 5 reinvented button styles. Delete
  `AdvancedNeumorphicButton`.
- **`StatCard`**, **`SectionHeader`**, **`GlassPanel`**, **`ProgressRing`** — replace duplicated stat cards and ad-hoc
  containers; used across menu / result / statistics / achievements.

---

## 5. Navigation & information architecture

- **Fold Pick-Side into Game Setup** → delete orphaned `pick_side_screen.dart`. One setup screen: board size · mode ·
  difficulty · **side (X/O)** · timer.
- **Merge History + Replay Viewer** into one "Replays" screen (list → tap → playback). Remove the duplicate route; keep
  a single canonical route.
- **Flow:** Splash → Main Menu → Setup → Game → Result; Stats / Achievements / Settings / Tutorial / About off the menu.
- **Split oversized screens** (`home` 643, `game_result` 601, `game_setup` 561, `main_menu` 560, `statistics` 518) into
  a screen shell + smaller section widgets, each targeting < 300 lines.
- *Route changes are permitted under the approved scope; navigation calls are updated to match. `main.dart` route table
  is updated accordingly.*

---

## 6. Screen redesigns (visual-first, low-text)

- **Splash** — calm the chaos: one tasteful animated logo; real load progress (not simulated).
- **Main Menu** — hero logo, large **PLAY** CTA, compact win-rate stat ring, icon-driven secondary nav. Fix "Welcome ,"
  typo.
- **Game Setup** — visual selectors: board-size tiles show mini-grids, difficulty chips, X/O picker as big tappable
  marks, timer toggle. Themed colors only.
- **Game (Home)** — collapse the 3 stacked gradient panels into ONE clean layout: **honest** turn indicator (real
  `currentPlayer`), board hero, slim move/timer bar, single back action.
- **Result** — keep elastic entrance + confetti; themed win/lose/draw; clear button hierarchy (Play Again primary).
- **Statistics** — dashboard: animated count-up numbers, themed `fl_chart` charts, progress rings — not text rows.
- **Achievements** — badge grid with tiers + progress rings, clear locked/unlocked states; fire missing achievement
  sound.
- **Settings / Tutorial / About** — consistent themed cards; visual icons over text walls.

---

## 7. Gameplay correctness & features

Edits are to **BLoC internals only**; the event/state **contract is unchanged** (no renamed/added/removed events or
state fields unless explicitly confirmed).

- **Honest turn indicator** — UI shows actual `currentPlayer`; correct in PvP and PvC.
- **AI race fix** — replace `Future.delayed`-as-synchronization + fragile `nextPlayer == 'O'` trigger with a
  deterministic "is it the AI's turn?" check; disable board taps during AI thinking.
- **Real "Impossible" tier** — true perfect play + deeper, move-ordered search (alpha-beta + center-first ordering) on
  4×4 / 5×5 so it is measurably stronger than Hard.
- **Finish Timed mode** — proper countdown, AI respects timeouts, remove `Phase 4` TODOs.

---

## 8. Animation / juice plan

- **Preserve:** mark-draw stroke, cell tap-scale, win-line glow, confetti, vibration patterns.
- **Add (tasteful, centralized in `app_motion.dart`):** shared-axis / fade-through page transitions, staggered card
  entrances, count-up stats, winning-line sweep, button press micro-interactions.
- Prefer implicit animations / `AnimatedSwitcher` / `Hero`; `const` constructors where possible; avoid jank.

---

## 9. Guardrails & discipline (execution rules)

**Untouchable:**
- `lib/utils/game_logic.dart`, `lib/logic/board_logic_4.dart`, `lib/logic/board_logic_5.dart` — DO NOT modify.
- Model shapes in `lib/models/` — read only.
- BLoC **public event/state contracts** and service **method signatures** — stable (fix internals, not the API).

**Permitted under approved scope:** BLoC internal bug/feature fixes (§7); route table + navigation updates (§5);
deletion of `pick_side_screen.dart` and the merged replay/history screen; pubspec font trim.

**Workflow:**
1. Read `main.dart`, all `blocs/`, `screens/`, `widgets/`, `pubspec.yaml`; summarize BLoC API surface each screen
   consumes.
2. Build `lib/theme/` tokens first, then the `widgets/common/` kit, then rebuild screens one at a time.
3. After each screen/widget: output `✅ [file] — what changed` + `flutter analyze` status.

**STOP-and-ask gates:** adding any dependency; changing `pubspec.yaml`; deleting any file; any change that would alter a
BLoC/model/service **public contract** (vs. internal fix).

---

## 10. Definition of done

- Every screen and widget visually rebuilt against the new design system.
- `flutter analyze` → zero errors; `flutter test` → green.
- All existing features functional: PvP/PvC, difficulty tiers (incl. real Impossible), board sizes 3/4/5, undo/redo,
  replays, settings persistence, stats, achievements, sound, vibration.
- Gameplay bugs fixed (turn indicator, AI race, Timed mode).
- Light/dark theme toggling works everywhere; no hardcoded colors in screens.
- Duplication removed (single board/cell/button/stat-card components).
- Animations smooth; no jank.
- Final checklist reported confirming each item.
