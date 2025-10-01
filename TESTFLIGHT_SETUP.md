# TestFlight Setup Guide for Couples Tempo

Complete guide to get your golf tempo app ready for TestFlight distribution.

## Prerequisites

- [ ] Apple Developer Account ($99/year)
- [ ] Xcode 15+ installed
- [ ] iOS device for testing
- [ ] Bundle ID reserved in Apple Developer Portal

## Step 1: Apple Developer Portal Setup

### Create App Identifier
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to Certificates, Identifiers & Profiles
3. Create new App ID: `com.[yourname].golfTempo`
4. Enable capabilities:
   - [ ] Background Modes
   - [ ] Push Notifications (optional)

### Create Provisioning Profile
1. Create iOS Distribution profile
2. Select your App ID
3. Choose distribution certificate
4. Download and install profile

## Step 2: Xcode Project Configuration

### Signing & Capabilities
```
1. Open project in Xcode
2. Select GolfTempo target
3. Go to Signing & Capabilities tab
4. Set Team: [Your Developer Team]
5. Bundle Identifier: com.[yourname].golfTempo
6. Enable Background Modes: Audio
```

### Info.plist Verification
Ensure these keys are set:
```xml
<key>CFBundleDisplayName</key>
<string>Couples Tempo</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<key>ITSAppUsesNonExemptEncryption</key>
<false/>

<key>LSApplicationCategoryType</key>
<string>public.app-category.sports</string>
```

## Step 3: App Store Connect Setup

### Create App Record
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "+" to create new app
3. Fill in details:
   - **Name**: Couples Tempo
   - **Bundle ID**: com.[yourname].golfTempo
   - **SKU**: golf-tempo-app
   - **Primary Language**: English

### App Information
```
Category: Sports
Content Rights: You have the rights or have permission to use

Age Ratings:
- No objectionable content
- Rating: 4+

App Privacy:
- Does Not Collect Data
- Add privacy policy URL (optional)
```

### TestFlight Information
```
Beta App Description:
"Couples Tempo helps golfers master Fred Couples' signature smooth swing tempo. This TestFlight version includes all core features for tempo training with audio, haptic, and visual feedback.

Please test:
- Tempo accuracy (should feel like 42 BPM)
- Audio synchronization
- Visual mode preferences
- Battery life during extended use
- Any crashes or performance issues

Your feedback helps improve the final release!"

Beta App Review Information:
- First Name: [Your Name]
- Last Name: [Your Name]
- Email: [Your Email]
- Phone: [Your Phone]

Test Information:
- Demo Account: Not needed
- Notes: App works offline, no account required
```

## Step 4: Build Archive & Upload

### Archive Build
```bash
1. In Xcode, select "Any iOS Device" or actual device
2. Product → Archive
3. Wait for archive to complete
4. Organizer window opens automatically
```

### Upload to App Store Connect
```bash
1. Click "Distribute App"
2. Select "App Store Connect"
3. Choose "Upload"
4. Select provisioning profile
5. Review content and upload
6. Wait for processing (10-30 minutes)
```

## Step 5: TestFlight Configuration

### Build Setup
1. Go to App Store Connect → TestFlight tab
2. Select uploaded build
3. Add export compliance: No encryption
4. Submit for beta review (if needed)

### Internal Testing
```
Add internal testers:
1. TestFlight → Internal Testing
2. Add up to 100 internal testers
3. Testers get immediate access
4. No review required for internal testing
```

### External Testing
```
Add external testers:
1. TestFlight → External Testing
2. Create test group
3. Add up to 10,000 external testers
4. Requires beta app review (1-2 days)
5. 90-day testing period
```

## Step 6: Tester Instructions

### Installation Email Template
```
Subject: Test Couples Tempo - Golf Swing Training App

Hi [Tester Name],

You're invited to test Couples Tempo, a golf swing tempo training app based on Fred Couples' signature smooth tempo.

TestFlight Installation:
1. Install TestFlight app from App Store
2. Tap this link: [TestFlight Link]
3. Install Couples Tempo
4. Open app and start practicing!

What to Test:
□ Tempo accuracy - Does it feel smooth like Fred Couples?
□ Audio quality - Clear tones for takeaway, top, impact?
□ Visual modes - Which mode helps most?
□ Practice sessions - Try different modes
□ Settings - Audio/haptic preferences
□ Stats tracking - Check session history

Test Scenarios:
1. 10-swing practice session
2. Background audio while recording video
3. Different visual modes
4. Volume and haptic settings
5. Extended use (15+ minutes)

Feedback Needed:
- Overall feel and usability
- Tempo accuracy vs real swing
- Audio timing and clarity
- Visual preference
- Any bugs or crashes
- Battery impact
- Feature requests

Send feedback via TestFlight or email: [your-email]

Thanks for helping make this the best golf tempo app!

[Your Name]
```

## Step 7: Version Management

### Build Numbers
```
Version 1.0.0:
- Build 1: Initial TestFlight release
- Build 2: Bug fixes
- Build 3: Feature improvements

Version 1.0.1:
- Build 4: Performance updates
- Build 5: UI improvements
```

### Release Notes Template
```
Build 1 (1.0.0):
- Initial TestFlight release
- Fred Couples signature tempo (42 BPM)
- 4 visual modes: Circle, Bar, Pendulum, Color
- Audio and haptic feedback
- Practice session tracking
- Preset configurations

Build 2 (1.0.0):
- Fixed audio synchronization issue
- Improved circle animation smoothness
- Better battery optimization
- Updated haptic patterns

Build 3 (1.0.0):
- Added volume control
- Enhanced dark mode support
- Fixed Core Data crash
- Improved landscape mode
```

## Step 8: Monitoring & Analytics

### TestFlight Metrics
Monitor in App Store Connect:
- [ ] Installation rate
- [ ] Session duration
- [ ] Crash reports
- [ ] Feedback comments
- [ ] Screenshots from testers

### Feedback Categories
```
Performance:
- Battery usage
- Audio latency
- Animation smoothness
- App startup time

Usability:
- Tempo feel and accuracy
- Visual clarity
- Audio quality
- Navigation ease

Features:
- Missing functionality
- Improvement suggestions
- Additional preset requests
- Export/sharing needs
```

## Step 9: Pre-Release Checklist

### Technical Validation
- [ ] App builds without warnings
- [ ] All features work on iOS 16.0+
- [ ] Tempo timing verified accurate
- [ ] Audio works with/without headphones
- [ ] Haptics work on supported devices
- [ ] Background audio continues
- [ ] Core Data saves/loads correctly
- [ ] Dark/Light mode switches
- [ ] Portrait/Landscape orientations
- [ ] No memory leaks detected

### TestFlight Submission
- [ ] Bundle ID matches App Store Connect
- [ ] Version number incremented
- [ ] Export compliance answered
- [ ] Beta app description updated
- [ ] Test information complete
- [ ] Internal testers added
- [ ] External testing group ready

## Step 10: Launch Preparation

### App Store Submission Prep
```
When TestFlight testing complete:
1. Address all critical feedback
2. Update version to 1.0.0 final
3. Create App Store screenshots
4. Write app description
5. Set pricing (Free/Paid)
6. Submit for App Store review
```

### Marketing Assets
```
Required Screenshots (iPhone):
- 6.7": 1290 x 2796 pixels
- 6.5": 1242 x 2688 pixels  
- 5.5": 1242 x 2208 pixels

Optional (iPad):
- 12.9": 2048 x 2732 pixels
- 11": 1640 x 2360 pixels

App Preview Video:
- 15-30 seconds
- Portrait orientation
- Show key features
```

## Troubleshooting

### Common Issues

**Build Upload Fails**
- Check bundle ID matches exactly
- Verify provisioning profile
- Increment build number
- Check export compliance setting

**TestFlight Not Showing**
- Wait 10-30 minutes for processing
- Check build status in App Store Connect
- Verify export compliance completed
- Refresh TestFlight app

**Tester Can't Install**
- Verify iOS version compatibility
- Check TestFlight invitation status
- Ensure device space available
- Try removing old builds first

**Audio Not Working**
- Check device volume settings
- Test with/without headphones
- Verify audio session configuration
- Check background audio capability

## Support Resources

- [TestFlight User Guide](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

Ready to share the smoothest tempo in golf! 🏌️‍♂️