# Sound Assets for XO Pro

## Required Sound Files

Place the following sound files in this directory:

### Game Sounds
1. **move.mp3** (100-200ms) - Soft click sound when placing X or O
2. **win.mp3** (1-2s) - Victory fanfare or celebration sound
3. **lose.mp3** (1-2s) - Defeat sound (softer, lower tone)
4. **draw.mp3** (1s) - Neutral completion sound
5. **button.mp3** (50-100ms) - UI button click sound
6. **achievement.mp3** (1-2s) - Special sound for achievement unlocks
7. **undo.mp3** (100ms) - Quick whoosh sound for undo action

## Recommended Sound Sources (Free)

### Option 1: Freesound.org
- https://freesound.org
- Search for: "click", "win", "lose", "achievement"
- License: CC0 or CC-BY

### Option 2: Zapsplat.com
- https://www.zapsplat.com
- Free with attribution
- High-quality game sound effects

### Option 3: Mixkit.co
- https://mixkit.co/free-sound-effects
- Free for commercial use
- Game UI sounds section

## Sound Specifications

- **Format:** MP3 (best compatibility)
- **Sample Rate:** 44.1kHz
- **Bit Rate:** 128-192kbps
- **Channels:** Stereo or Mono
- **Volume:** Normalized to -3dB

## Installation

1. Download sound files from sources above
2. Rename files to match the names listed
3. Place in this directory (assets/sounds/)
4. Run `flutter pub get` to refresh assets
5. Restart the app

## Current Status

🔴 No sound files present - Sounds will fail silently until files are added

## Testing Sounds

Run the app and toggle sounds in Settings > Sound Effects to test each sound:
- Tap cells to hear move.mp3
- Win a game to hear win.mp3
- Lose to AI to hear lose.mp3
- Get a draw to hear draw.mp3
- Click buttons to hear button.mp3
- Unlock achievement to hear achievement.mp3
- Undo a move to hear undo.mp3
