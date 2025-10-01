# Xcode Project Setup Instructions

## Current Build Errors - How to Fix

The build errors are happening because the source files need to be properly added to the Xcode project target. Here's how to fix it:

### Step 1: Clean Up Duplicate Files (DONE)
✅ Removed duplicate ContentView.swift from Views folder
✅ Renamed myTempoGolfApp.swift to MyTempoGolfApp.swift

### Step 2: Add Source Files to Xcode Project

1. **Open the project:**
   ```
   open myTempoGolf.xcodeproj
   ```

2. **Remove existing files that are causing conflicts:**
   - In Xcode Navigator, find any files showing errors
   - Right-click → Delete → "Move to Trash"

3. **Add all source files properly:**
   - Right-click on "myTempoGolf" folder in Navigator
   - Choose "Add Files to 'myTempoGolf'"
   - Navigate to your project folder
   - Select these folders (hold Cmd to select multiple):
     - `Models/`
     - `Views/`
     - `ViewModels/`
     - `Utilities/`
     - `MyTempoGolf.xcdatamodeld/`
   - Make sure "Add to target: myTempoGolf" is ✅ checked
   - Click "Add"

4. **Verify file structure in Xcode:**
   Your Navigator should show:
   ```
   myTempoGolf
   ├── MyTempoGolfApp.swift
   ├── ContentView.swift
   ├── Models/
   │   ├── TempoSettings.swift
   │   └── SwingSession.swift
   ├── Views/
   │   ├── TempoView.swift
   │   ├── SettingsView.swift
   │   ├── StatsView.swift
   │   └── PresetsView.swift
   ├── ViewModels/
   │   ├── TempoViewModel.swift
   │   └── SettingsViewModel.swift
   ├── Utilities/
   │   ├── AudioManager.swift
   │   └── HapticManager.swift
   ├── MyTempoGolf.xcdatamodeld
   ├── Assets.xcassets
   └── Info.plist
   ```

### Step 3: Configure Project Settings

1. **Select the project** (blue icon at top of Navigator)
2. **Select "myTempoGolf" target**
3. **Go to "Signing & Capabilities" tab:**
   - Team: Select your developer team
   - Bundle Identifier: `com.[yourname].mytempogolf`
   
4. **Add Background Modes capability:**
   - Click "+ Capability"
   - Search for "Background Modes"
   - Check ✅ "Audio, AirPlay, and Picture in Picture"

5. **Go to "Build Settings" tab:**
   - Search for "iOS Deployment Target"
   - Set to "16.0" or higher

### Step 4: Fix Import Issues

If you still get import errors, add these frameworks:
1. Select project → Target → "General" tab
2. Scroll to "Frameworks, Libraries, and Embedded Content"
3. Click "+" and add:
   - AVFoundation.framework
   - CoreHaptics.framework
   - Charts.framework (for statistics)

### Step 5: Build and Test

1. **Clean build folder:** Product → Clean Build Folder
2. **Build:** Cmd+B
3. **Run:** Cmd+R

## If You Still Get Errors

### Missing Charts Framework
The StatsView uses Charts framework. If it's not available:

**Option 1: Remove Charts (Simplest)**
1. Open `Views/StatsView.swift`
2. Replace `import Charts` with `import SwiftUI`
3. Remove the Chart components and replace with simple VStack/HStack layouts

**Option 2: Add Charts Framework**
1. Select project → Target → "General"
2. Frameworks section → "+"
3. Add Charts.framework (iOS 16+ required)

### Core Data Model Issues
If Core Data errors:
1. Select `MyTempoGolf.xcdatamodeld`
2. Make sure it's added to target
3. Verify the model name matches in `SwingSession.swift`

## Quick Test Build

After following steps above, try this minimal test:
1. Comment out Charts import in StatsView.swift if needed
2. Build (Cmd+B)
3. Should compile successfully
4. Run on simulator to test basic functionality

## Final Structure Check

Your project should have NO duplicate files and all source files should be properly added to the target. The Navigator should match the structure shown in Step 2.

---

**If you're still having issues, take another screenshot of the build errors and I'll help debug further!** 🚀