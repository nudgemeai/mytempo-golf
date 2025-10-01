import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var tempoViewModel: TempoViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TempoView()
                .tabItem {
                    Image(systemName: "metronome")
                    Text("Tempo")
                }
                .tag(0)
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Stats")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.green)
    }
}

// MARK: - Main Tempo View
struct TempoView: View {
    @EnvironmentObject var viewModel: TempoViewModel
    @EnvironmentObject var audioManager: AudioManager
    @State private var showingPresets = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(viewModel.settings.bpm) BPM")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Fred Couples 3.3:1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(viewModel.swingCount)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Swings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Main Visual Tempo Indicator
                ZStack {
                    switch viewModel.settings.visualMode {
                    case .circle:
                        CircleTempoView(progress: viewModel.progress, phase: viewModel.currentPhase)
                    case .bar:
                        BarTempoView(progress: viewModel.progress, phase: viewModel.currentPhase)
                    case .pendulum:
                        PendulumTempoView(progress: viewModel.progress, phase: viewModel.currentPhase)
                    case .color:
                        ColorTempoView(progress: viewModel.progress, phase: viewModel.currentPhase)
                    }
                }
                .frame(height: 250)
                
                // Phase indicators
                HStack(spacing: 15) {
                    ForEach(SwingPhase.allCases, id: \.self) { phase in
                        VStack {
                            Circle()
                                .fill(viewModel.currentPhase == phase ? phase.color : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                            
                            Text(phaseText(for: phase))
                                .font(.caption2)
                                .foregroundColor(viewModel.currentPhase == phase ? .primary : .secondary)
                        }
                    }
                }
                
                // Control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        print("🔥 Play button tapped!")
                        viewModel.toggleTempo()
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        viewModel.stopTempo()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                }
                
                // Test Audio Button (for debugging)
                Button(action: {
                    print("🧪 Test audio button tapped!")
                    audioManager.testAudio()
                }) {
                    Text("🔊 Test Audio")
                        .font(.caption)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                }
                .padding(.top, 10)
                
                // Quick Settings
                VStack(spacing: 15) {
                    HStack {
                        Text("Visual Mode")
                            .font(.headline)
                        Spacer()
                        Picker("Visual Mode", selection: $viewModel.settings.visualMode) {
                            ForEach(VisualMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("Practice Mode")
                            .font(.headline)
                        Spacer()
                        Picker("Practice Mode", selection: $viewModel.settings.practiceMode) {
                            ForEach(PracticeMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Toggle("Audio", isOn: $viewModel.settings.isAudioEnabled)
                        Spacer()
                        Toggle("Haptic", isOn: $viewModel.settings.isHapticEnabled)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Bottom padding for tab bar
                Spacer(minLength: 80)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationTitle("MyTempo Golf")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Presets") {
                    showingPresets = true
                }
                .foregroundColor(.green)
            }
        }
        .sheet(isPresented: $showingPresets) {
            PresetsView()
        }
    }
    .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func phaseText(for phase: SwingPhase) -> String {
        switch phase {
        case .takeaway: return "Take"
        case .backswing: return "Back"
        case .pause: return "Pause"
        case .downswing: return "Down"
        case .impact: return "Impact"
        case .followthrough: return "Follow"
        }
    }
}

// MARK: - Presets View
struct PresetsView: View {
    @EnvironmentObject var viewModel: TempoViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Fred Couples Presets") {
                    PresetRow(
                        name: "Classic",
                        description: "Original 3.3:1 ratio",
                        preset: TempoSettings.couplesClassic
                    )
                    
                    PresetRow(
                        name: "Smooth",
                        description: "Slightly slower tempo",
                        preset: TempoSettings.couplesSmooth
                    )
                    
                    PresetRow(
                        name: "Driver",
                        description: "Faster for driver swings",
                        preset: TempoSettings.couplesDriver
                    )
                    
                    PresetRow(
                        name: "Training",
                        description: "More aggressive tempo",
                        preset: TempoSettings.trainingTempo
                    )
                }
            }
            .navigationTitle("Tempo Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PresetRow: View {
    let name: String
    let description: String
    let preset: TempoSettings
    @EnvironmentObject var viewModel: TempoViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            viewModel.loadPreset(preset)
            dismiss()
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(preset.bpm) BPM")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Stats View
struct StatsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Session stats
                    VStack(spacing: 15) {
                        StatCard(
                            title: "Total Swings",
                            value: "\(settingsViewModel.totalSwings)",
                            icon: "figure.golf"
                        )
                        
                        StatCard(
                            title: "Total Sessions",
                            value: "\(settingsViewModel.totalSessions)",
                            icon: "calendar"
                        )
                        
                        StatCard(
                            title: "Average Duration",
                            value: formatDuration(settingsViewModel.averageSessionDuration),
                            icon: "clock"
                        )
                        
                        StatCard(
                            title: "Current Streak",
                            value: "\(settingsViewModel.currentStreak) days",
                            icon: "flame"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        settingsViewModel.resetAllData()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var hapticManager: HapticManager
    
    var body: some View {
        NavigationView {
            Form {
                Section("Audio Settings") {
                    Toggle("Audio Enabled", isOn: $audioManager.isEnabled)
                    
                    HStack {
                        Text("Volume")
                        Spacer()
                        Slider(value: Binding(
                            get: { Double(audioManager.volume) },
                            set: { audioManager.setVolume(Float($0)) }
                        ), in: 0...1)
                        .frame(width: 100)
                    }
                }
                
                Section("Haptic Settings") {
                    Toggle("Haptic Feedback", isOn: $hapticManager.isEnabled)
                    Toggle("Vibrate on Silent", isOn: $settingsViewModel.vibrateOnSilent)
                }
                
                Section("Display") {
                    Toggle("Dark Mode", isOn: $settingsViewModel.isDarkMode)
                    Toggle("High Contrast", isOn: $settingsViewModel.highContrastMode)
                    Toggle("Show BPM", isOn: $settingsViewModel.showBPM)
                }
                
                Section("General") {
                    Toggle("Background Audio", isOn: $settingsViewModel.backgroundAudioEnabled)
                    Toggle("Disable Auto-Lock", isOn: $settingsViewModel.isAutoLockDisabled)
                        .onChange(of: settingsViewModel.isAutoLockDisabled) { newValue in
                            UIApplication.shared.isIdleTimerDisabled = newValue
                        }
                }
                
                Section("Data") {
                    Button("Export Session Data") {
                        let csvData = settingsViewModel.exportData()
                        // TODO: Share sheet for CSV export
                        print("CSV Export: \(csvData)")
                    }
                    
                    Button("Reset All Data") {
                        settingsViewModel.resetAllData()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Visual Mode Components

struct CircleTempoView: View {
    let progress: Double
    let phase: SwingPhase
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(phase.color, lineWidth: 8)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            // Center content
            VStack {
                Text(phaseText(for: phase))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(phase.color)
                
                Text(String(format: "%.1f%%", progress * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func phaseText(for phase: SwingPhase) -> String {
        switch phase {
        case .takeaway: return "Take"
        case .backswing: return "Back"
        case .pause: return "Pause"
        case .downswing: return "Down"
        case .impact: return "Impact"
        case .followthrough: return "Follow"
        }
    }
}

struct BarTempoView: View {
    let progress: Double
    let phase: SwingPhase
    
    var body: some View {
        VStack(spacing: 20) {
            Text(phaseText(for: phase))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(phase.color)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 20)
                    .cornerRadius(10)
                
                Rectangle()
                    .fill(phase.color)
                    .frame(width: 200 * progress, height: 20)
                    .cornerRadius(10)
                    .animation(.linear(duration: 0.1), value: progress)
            }
            
            Text(String(format: "%.1f%%", progress * 100))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func phaseText(for phase: SwingPhase) -> String {
        switch phase {
        case .takeaway: return "Takeaway"
        case .backswing: return "Backswing"
        case .pause: return "Pause"
        case .downswing: return "Downswing"
        case .impact: return "Impact"
        case .followthrough: return "Follow Through"
        }
    }
}

struct PendulumTempoView: View {
    let progress: Double
    let phase: SwingPhase
    
    var body: some View {
        VStack(spacing: 20) {
            Text(phaseText(for: phase))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(phase.color)
            
            ZStack {
                // Golf swing arc background (quarter circle)
                Path { path in
                    let center = CGPoint(x: 90, y: 90)
                    let radius: CGFloat = 70
                    path.addArc(center: center, radius: radius, 
                               startAngle: .degrees(45), 
                               endAngle: .degrees(135), 
                               clockwise: false)
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                .frame(width: 180, height: 180)
                
                // Golf club shaft
                Rectangle()
                    .fill(phase.color)
                    .frame(width: 3, height: 90)
                    .offset(y: -45)
                    .rotationEffect(.degrees(golfSwingAngle))
                    .animation(.linear(duration: 0.05), value: golfSwingAngle)
                
                // Golf club head
                RoundedRectangle(cornerRadius: 3)
                    .fill(phase.color)
                    .frame(width: 12, height: 8)
                    .offset(y: -90)
                    .rotationEffect(.degrees(golfSwingAngle))
                    .animation(.linear(duration: 0.05), value: golfSwingAngle)
                
                // Center grip/hands
                Circle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 8, height: 8)
                
                // Swing direction indicator
                Text(swingDirection)
                    .font(.caption)
                    .foregroundColor(phase.color)
                    .offset(y: 50)
            }
            
            HStack {
                Text(String(format: "%.1f%%", progress * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(tempoTiming)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var golfSwingAngle: Double {
        // Realistic golf swing angles:
        // Takeaway: 0° (address)
        // Backswing: +75° (top of backswing)
        // Pause: +75° (pause at top)
        // Downswing: 0° to -15° (through impact)
        // Impact: -10° (slightly past vertical)
        // Follow: -30° (follow through)
        
        switch phase {
        case .takeaway:
            return progress * 15 // 0° to 15°
        case .backswing:
            return 15 + (progress * 60) // 15° to 75°
        case .pause:
            return 75 // Hold at top
        case .downswing:
            return 75 - (progress * 85) // 75° to -10°
        case .impact:
            return -10 // Moment of impact
        case .followthrough:
            return -10 - (progress * 20) // -10° to -30°
        }
    }
    
    private var swingDirection: String {
        switch phase {
        case .takeaway, .backswing:
            return "⬆️ BACK"
        case .pause:
            return "⏸️ PAUSE"
        case .downswing, .impact:
            return "⬇️ DOWN"
        case .followthrough:
            return "➡️ THROUGH"
        }
    }
    
    private var tempoTiming: String {
        switch phase {
        case .takeaway, .backswing:
            return "1.1s"
        case .pause:
            return "0.1s"
        case .downswing, .impact:
            return "0.33s"
        case .followthrough:
            return "Follow"
        }
    }
    
    private func phaseText(for phase: SwingPhase) -> String {
        switch phase {
        case .takeaway: return "Takeaway"
        case .backswing: return "Backswing"
        case .pause: return "Top Pause"
        case .downswing: return "Downswing"
        case .impact: return "IMPACT!"
        case .followthrough: return "Follow Through"
        }
    }
}

struct ColorTempoView: View {
    let progress: Double
    let phase: SwingPhase
    
    var body: some View {
        VStack(spacing: 20) {
            Text(phaseText(for: phase))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Rectangle()
                .fill(phase.color)
                .frame(width: 200, height: 200)
                .cornerRadius(20)
                .overlay(
                    VStack {
                        Text(String(format: "%.1f%%", progress * 100))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                )
                .animation(.easeInOut(duration: 0.3), value: phase)
        }
    }
    
    private func phaseText(for phase: SwingPhase) -> String {
        switch phase {
        case .takeaway: return "TAKEAWAY"
        case .backswing: return "BACKSWING"
        case .pause: return "PAUSE"
        case .downswing: return "DOWNSWING"
        case .impact: return "IMPACT!"
        case .followthrough: return "FOLLOW THROUGH"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TempoViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(AudioManager())
        .environmentObject(HapticManager())
}