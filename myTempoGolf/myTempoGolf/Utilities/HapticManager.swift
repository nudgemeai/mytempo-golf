import Foundation
import CoreHaptics
import UIKit

class HapticManager: ObservableObject {
    @Published var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                stopAllHaptics()
            }
        }
    }
    
    private var hapticEngine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private var isEngineAvailable = false
    
    init() {
        setupHapticEngine()
        prepareHaptics()
        setupNotifications()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device doesn't support haptics")
            isEngineAvailable = false
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            
            hapticEngine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.isEngineAvailable = false
                self?.restartEngine()
            }
            
            hapticEngine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                self?.restartEngine()
            }
            
            try hapticEngine?.start()
            isEngineAvailable = true
            print("Haptic engine started successfully")
            
        } catch {
            print("Failed to create haptic engine: \(error)")
            isEngineAvailable = false
        }
    }
    
    private func restartEngine() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            do {
                try self.hapticEngine?.start()
                self.isEngineAvailable = true
                print("Haptic engine restarted")
            } catch {
                print("Failed to restart haptic engine: \(error)")
                self.isEngineAvailable = false
            }
        }
    }
    
    private func prepareHaptics() {
        DispatchQueue.main.async {
            self.impactLight.prepare()
            self.impactMedium.prepare()
            self.impactHeavy.prepare()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhaseChanged(_:)),
            name: .tempoPhaseChanged,
            object: nil
        )
    }
    
    @objc private func handlePhaseChanged(_ notification: Notification) {
        guard isEnabled,
              let phase = notification.object as? SwingPhase else { return }
        
        playHaptic(for: phase)
    }
    
    func playHaptic(for phase: SwingPhase) {
        guard isEnabled else { return }
        
        DispatchQueue.main.async {
            switch phase {
            case .takeaway:
                self.impactLight.impactOccurred()
            case .pause:
                self.impactMedium.impactOccurred()
            case .impact:
                self.impactHeavy.impactOccurred()
            default:
                break
            }
        }
    }
    
    func playCustomHaptic(intensity: Float, sharpness: Float, duration: Double = 0.1) {
        guard isEnabled, isEngineAvailable, let engine = hapticEngine else {
            // Fallback to basic haptic
            DispatchQueue.main.async {
                if intensity > 0.8 {
                    self.impactHeavy.impactOccurred()
                } else if intensity > 0.5 {
                    self.impactMedium.impactOccurred()
                } else {
                    self.impactLight.impactOccurred()
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            do {
                let hapticEvent = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                    ],
                    relativeTime: 0
                )
                
                let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {
                print("Failed to play custom haptic: \(error)")
                // Fallback to basic haptic
                if intensity > 0.8 {
                    self.impactHeavy.impactOccurred()
                } else if intensity > 0.5 {
                    self.impactMedium.impactOccurred()
                } else {
                    self.impactLight.impactOccurred()
                }
            }
        }
    }
    
    func playTempoHaptic(phase: SwingPhase) {
        switch phase {
        case .takeaway:
            playCustomHaptic(intensity: 0.3, sharpness: 0.3)
        case .pause:
            playCustomHaptic(intensity: 0.6, sharpness: 0.8)
        case .impact:
            playCustomHaptic(intensity: 1.0, sharpness: 1.0)
        default:
            break
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.isEnabled = enabled
        }
    }
    
    private func stopAllHaptics() {
        // Stop any ongoing haptic patterns
        // Basic impact generators don't need explicit stopping
    }
    
    private func cleanup() {
        NotificationCenter.default.removeObserver(self)
        
        DispatchQueue.main.async {
            self.hapticEngine?.stop()
            self.isEngineAvailable = false
        }
    }
}