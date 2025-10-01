# Couples Tempo - Golf Swing Tempo Training App

A premium SwiftUI iOS app designed to help golfers master Fred Couples' signature smooth tempo. Perfect for practice and tempo training with precise timing, visual feedback, and audio cues.

## Features

### 🎯 Fred Couples Signature Tempo
- **3.3:1 Ratio**: Authentic Fred Couples backswing to downswing ratio
- **Precise Timing**: 1.1s backswing, 0.1s pause, 0.33s downswing
- **42 BPM**: Matches Fred's legendary smooth tempo
- **Signature Pause**: The characteristic hold at the top

### 🎵 Audio & Haptic Feedback
- **Pure Tone Generation**: Crystal clear 440Hz, 880Hz, and 1760Hz tones
- **Haptic Patterns**: Light, medium, and strong feedback for each phase
- **Background Audio**: Continue practice while video recording
- **Volume Control**: Adjustable audio levels

### 📊 Visual Training Modes
- **Circle Mode**: Expanding/contracting circle visualization
- **Bar Mode**: Linear progress indicator
- **Pendulum Mode**: Realistic metronome animation
- **Color Mode**: Phase-based color transitions

### 🏌️ Practice Modes
- **Continuous Loop**: Endless repetition for groove building
- **Single Swing**: One perfect swing practice
- **Set Practice**: Custom swing counts (10, 20, 50)
- **Progressive**: Gradually building tempo consistency

### 📈 Statistics & Tracking
- **Session History**: Track all practice sessions
- **Swing Counting**: Automatic swing tallies
- **Consistency Scoring**: Monitor tempo improvements
- **Streak Tracking**: Daily practice motivation
- **Export Data**: CSV export for analysis

### ⚙️ Customization
- **Tempo Presets**: Couples Classic, Smooth, Driver, Training
- **Fine Tuning**: Adjust ratio (2.5:1 to 4:1) and pause duration
- **Custom Presets**: Save your preferred settings
- **Dark/Light Mode**: Optimal visibility in any condition

## Technical Requirements

- **iOS 16.0+**
- **iPhone/iPad Compatible**
- **No Internet Required**
- **Background Audio Support**
- **Haptic Engine Support**

## Installation

### Xcode Setup
1. Clone or download the project
2. Open `GolfTempo.xcodeproj` in Xcode 15+
3. Set your Team in Signing & Capabilities
4. Update Bundle Identifier: `com.[yourname].golfTempo`
5. Build and run on device

### TestFlight Deployment
1. Archive the app in Xcode
2. Upload to App Store Connect
3. Create TestFlight build
4. Add internal/external testers
5. Share TestFlight link

## Project Structure

```
GolfTempo/
├── GolfTempoApp.swift          # Main app entry point
├── Models/
│   ├── TempoSettings.swift     # Tempo configuration
│   └── SwingSession.swift      # Core Data model
├── ViewModels/
│   ├── TempoViewModel.swift    # Main tempo logic
│   └── SettingsViewModel.swift # Settings management
├── Views/
│   ├── ContentView.swift       # Tab navigation
│   ├── TempoView.swift         # Main tempo screen
│   ├── SettingsView.swift      # Settings screen
│   ├── StatsView.swift         # Statistics screen
│   └── PresetsView.swift       # Preset management
├── Utilities/
│   ├── AudioManager.swift      # Audio generation
│   └── HapticManager.swift     # Haptic feedback
└── Resources/
    ├── Assets.xcassets/        # App icons & colors
    ├── Info.plist             # App configuration
    └── GolfTempo.xcdatamodeld/ # Core Data model
```

## Fred Couples Tempo Specifications

The app implements Fred Couples' exact swing timing:

- **Backswing**: 33 frames @ 30fps = 1.1 seconds
- **Pause**: 3 frames @ 30fps = 0.1 seconds  
- **Downswing**: 10 frames @ 30fps = 0.33 seconds
- **Total**: 1.43 seconds (42 BPM equivalent)
- **Ratio**: 3.3:1 (backswing:downswing)

## Audio System

The app generates pure tones programmatically:

- **Takeaway**: 440Hz (Low A) - Smooth start
- **Top**: 880Hz (High A) - Pause indicator  
- **Impact**: 1760Hz (Very High A) - Strong finish

## Core Data Schema

```swift
SwingSession Entity:
- id: UUID
- date: Date
- swingCount: Int32
- duration: Double
- tempoRatio: Double
- pauseDuration: Double
- practiceMode: String
- consistencyScore: Double
```

## Privacy & Permissions

- **Motion**: Optional for future swing analysis
- **Background Audio**: For continuous practice
- **No Data Collection**: All data stays on device
- **Export Only**: User controls data sharing

## Testing Checklist

Before TestFlight upload:

- [ ] Tempo timing accurate for 100+ swings
- [ ] Audio stays synchronized with visuals
- [ ] Haptic feedback works on all supported devices
- [ ] Background audio continues during screen recording
- [ ] All visual modes render correctly
- [ ] Settings persist between app launches
- [ ] Core Data saves session history
- [ ] Statistics calculate correctly
- [ ] Export functionality works
- [ ] Dark/Light mode transitions smoothly
- [ ] Battery usage optimized
- [ ] Works with AirPods/Bluetooth audio
- [ ] Landscape/Portrait orientations supported

## TestFlight Test Notes Template

```
Couples Tempo v1.0.0 (Build 1)

What's New:
- Initial release with Fred Couples signature tempo
- 4 visual modes: Circle, Bar, Pendulum, Color
- Audio and haptic feedback
- Practice session tracking
- Preset tempo configurations

Test Focus:
1. Tempo accuracy - Use with metronome app to verify 42 BPM
2. Audio quality - Test with headphones and speakers
3. Visual smoothness - Check 60fps animations
4. Background mode - Test while recording video
5. Battery life - Extended practice sessions

Known Issues:
- None in this build

Feedback Needed:
- Tempo feel and accuracy
- Audio clarity and timing
- Visual preference (which mode works best)
- Battery performance during long sessions
- Any crashes or unexpected behavior
```

## Support

For issues or feedback:
- Create GitHub issue
- Email: [your-email]
- TestFlight feedback form

## License

Private use only. Not for distribution or commercial use.

---

**"Finding Your Rhythm"** - Master the smoothest tempo in golf with precision timing and professional feedback.