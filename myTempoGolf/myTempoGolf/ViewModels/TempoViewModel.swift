import Foundation
import Combine
import SwiftUI

class TempoViewModel: ObservableObject {
    @Published var settings = TempoSettings()
    @Published var isPlaying = false
    @Published var currentPhase: SwingPhase = .takeaway
    @Published var progress: Double = 0.0
    @Published var swingCount = 0
    @Published var sessionDuration: TimeInterval = 0
    @Published var isSessionActive = false
    
    private var swingTimer: Timer?
    private var sessionTimer: Timer?
    private var sessionStartTime: Date?
    private var swingStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // Fred Couples specific timing
    private let updateInterval: TimeInterval = 1.0/60.0 // 60 FPS for smooth animation
    
    init() {
        print("🔗 TempoViewModel init called")
    }
    
    deinit {
        cleanup()
    }
    
    func startTempo() {
        print("🏌️ startTempo() called - current isPlaying: \(isPlaying)")
        
        guard !isPlaying else {
            print("❌ Already playing, ignoring")
            return
        }
        
        print("✅ Starting tempo - setting isPlaying = true")
        isPlaying = true
        
        // Start session directly - don't rely on Combine
        startSession()
    }
    
    func stopTempo() {
        print("🛑 stopTempo() called")
        isPlaying = false
        stopSession()
    }
    
    func toggleTempo() {
        print("🔄 toggleTempo() called - current state: \(isPlaying)")
        if isPlaying {
            stopTempo()
        } else {
            startTempo()
        }
    }
    
    private func startSession() {
        print("🎬 Starting session...")
        sessionStartTime = Date()
        swingCount = 0
        isSessionActive = true
        
        DispatchQueue.main.async {
            self.currentPhase = .takeaway
            self.progress = 0.0
        }
        
        startSessionTimer()
        startSwingCycle()
        print("✅ Session started successfully")
    }
    
    private func stopSession() {
        print("⏹️ Stopping session...")
        invalidateTimers()
        
        if let startTime = sessionStartTime, swingCount > 0 {
            let duration = Date().timeIntervalSince(startTime)
            saveSession(duration: duration)
        }
        
        resetToInitialState()
    }
    
    private func startSessionTimer() {
        print("⏱️ Starting session timer...")
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.sessionStartTime else { return }
            DispatchQueue.main.async {
                self.sessionDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func startSwingCycle() {
        print("🔄 Starting swing cycle...")
        guard isPlaying else {
            print("❌ Not playing, can't start swing cycle")
            return
        }
        
        swingStartTime = Date()
        
        DispatchQueue.main.async {
            self.currentPhase = .takeaway
            self.progress = 0.0
        }
        
        print("⏱️ Creating swing timer with interval: \(updateInterval)")
        // High-frequency timer for smooth animation
        swingTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateSwingProgress()
        }
        
        // Schedule phase transitions
        schedulePhaseTransitions()
        print("✅ Swing cycle started")
    }
    
    private func schedulePhaseTransitions() {
        print("📅 Scheduling phase transitions...")
        guard isPlaying else { 
            print("❌ Not playing, skipping phase transitions")
            return 
        }
        
        // Capture settings values locally to avoid accessing deallocated self
        let backswingDuration = settings.backswingDuration
        let pauseDuration = settings.pauseDuration
        let downswingDuration = settings.downswingDuration
        let totalDuration = settings.totalSwingDuration
        
        print("⏰ Durations - Back: \(backswingDuration), Pause: \(pauseDuration), Down: \(downswingDuration)")
        
        // Use DispatchQueue.main.asyncAfter for precise timing
        let queue = DispatchQueue.main
        
        // Takeaway -> Backswing (immediate)
        queue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print("🔄 Transitioning to backswing")
            self?.safeTransitionToPhase(.backswing)
        }
        
        // Backswing -> Pause
        queue.asyncAfter(deadline: .now() + backswingDuration) { [weak self] in
            print("⏸️ Transitioning to pause")
            self?.safeTransitionToPhase(.pause)
        }
        
        // Pause -> Downswing
        queue.asyncAfter(deadline: .now() + backswingDuration + pauseDuration) { [weak self] in
            print("⬇️ Transitioning to downswing")
            self?.safeTransitionToPhase(.downswing)
        }
        
        // Downswing -> Impact
        let impactTime = backswingDuration + pauseDuration + (downswingDuration * 0.8)
        queue.asyncAfter(deadline: .now() + impactTime) { [weak self] in
            print("💥 Transitioning to impact")
            self?.safeTransitionToPhase(.impact)
        }
        
        // Impact -> Follow through
        queue.asyncAfter(deadline: .now() + backswingDuration + pauseDuration + downswingDuration) { [weak self] in
            print("🔄 Transitioning to followthrough")
            self?.safeTransitionToPhase(.followthrough)
        }
        
        // Complete swing
        queue.asyncAfter(deadline: .now() + totalDuration + 0.2) { [weak self] in
            print("✅ Completing swing")
            self?.completeSwing()
        }
    }
    
    private func safeTransitionToPhase(_ phase: SwingPhase) {
        guard isPlaying else { 
            print("❌ Not playing, skipping phase transition to \(phase)")
            return 
        }
        
        DispatchQueue.main.async {
            print("🔄 Phase changed to: \(phase)")
            self.currentPhase = phase
            
            // Post notification safely
            NotificationCenter.default.post(name: .tempoPhaseChanged, object: phase)
        }
    }
    
    private func updateSwingProgress() {
        guard isPlaying, let startTime = swingStartTime else { 
            return 
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let totalDuration = settings.totalSwingDuration
        let newProgress = min(elapsed / totalDuration, 1.0)
        
        // Only log every 30th update to avoid spam
        if Int(elapsed * 100) % 30 == 0 {
            print("📊 Progress: \(String(format: "%.1f", newProgress * 100))% - Phase: \(currentPhase)")
        }
        
        DispatchQueue.main.async {
            self.progress = newProgress
            self.updatePhaseProgress(elapsed: elapsed)
        }
    }
    
    private func updatePhaseProgress(elapsed: TimeInterval) {
        // Capture settings values to avoid accessing deallocated self
        let backswingDuration = settings.backswingDuration
        let pauseDuration = settings.pauseDuration
        let downswingDuration = settings.downswingDuration
        
        switch currentPhase {
        case .takeaway, .backswing:
            let phaseProgress = elapsed / backswingDuration
            progress = min(phaseProgress * 0.7, 0.7) // 70% of total progress
            
        case .pause:
            progress = 0.7 // Hold at 70%
            
        case .downswing:
            let downswingStart = backswingDuration + pauseDuration
            let phaseElapsed = elapsed - downswingStart
            let phaseProgress = phaseElapsed / downswingDuration
            progress = 0.7 + (phaseProgress * 0.3) // 70% to 100%
            
        case .impact, .followthrough:
            progress = 1.0
        }
    }
    
    private func completeSwing() {
        guard isPlaying else { 
            print("❌ Not playing, skipping swing completion")
            return 
        }
        
        print("🏁 Swing completed!")
        
        DispatchQueue.main.async {
            self.swingCount += 1
            print("📊 Swing count: \(self.swingCount)")
            
            // Check if we should continue based on practice mode
            if self.shouldContinueSwing() {
                print("🔄 Continuing with next swing...")
                // Small pause between swings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if self.isPlaying {
                        self.startSwingCycle()
                    }
                }
            } else {
                print("🛑 Practice session complete")
                self.stopTempo()
            }
        }
    }
    
    private func shouldContinueSwing() -> Bool {
        switch settings.practiceMode {
        case .continuous:
            return true
        case .single:
            return false
        case .set:
            return swingCount < settings.customSwingCount
        case .progressive:
            // Gradually increase tempo (reduce total duration)
            if swingCount > 0 && swingCount % 10 == 0 {
                DispatchQueue.main.async {
                    self.settings.ratio = max(2.5, self.settings.ratio - 0.1)
                }
            }
            return true
        }
    }
    
    private func resetToInitialState() {
        DispatchQueue.main.async {
            self.currentPhase = .takeaway
            self.progress = 0.0
            self.sessionDuration = 0
            self.isSessionActive = false
        }
    }
    
    private func invalidateTimers() {
        print("🧹 Invalidating timers...")
        sessionTimer?.invalidate()
        sessionTimer = nil
        swingTimer?.invalidate()
        swingTimer = nil
    }
    
    private func saveSession(duration: TimeInterval) {
        let session = SwingSession(
            swingCount: swingCount,
            duration: duration,
            settings: settings
        )
        
        // Post notification to save session
        NotificationCenter.default.post(name: .sessionCompleted, object: session)
    }
    
    private func cleanup() {
        print("🧹 TempoViewModel cleanup")
        invalidateTimers()
        cancellables.removeAll()
    }
    
    // Preset management
    func loadPreset(_ preset: TempoSettings) {
        print("🎛️ Loading preset: \(preset.ratio):1 ratio, \(preset.bpm) BPM")
        DispatchQueue.main.async {
            self.settings = preset
            print("✅ Preset loaded: \(self.settings.ratio):1, \(self.settings.bpm) BPM")
        }
    }
    
    func saveCustomPreset(name: String) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "preset_\(name)")
        }
    }
    
    func loadCustomPreset(name: String) -> TempoSettings? {
        guard let data = UserDefaults.standard.data(forKey: "preset_\(name)"),
              let preset = try? JSONDecoder().decode(TempoSettings.self, from: data) else {
            return nil
        }
        return preset
    }
}

extension Notification.Name {
    static let tempoPhaseChanged = Notification.Name("tempoPhaseChanged")
    static let sessionCompleted = Notification.Name("sessionCompleted")
}